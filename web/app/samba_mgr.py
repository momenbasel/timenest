"""Thin wrapper around the Samba container.

We shell out to ``docker exec`` rather than re-implementing Samba's
passdb protocol because tdbsam is version-sensitive and a plain shell
call is trivially auditable. The helper scripts in ./scripts/ do the
actual work inside the container.
"""

from __future__ import annotations

import asyncio
import logging
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

from .config import Settings

log = logging.getLogger(__name__)


_USERNAME_RE = re.compile(r"^[a-z_][a-z0-9_-]{0,31}$")
_SESSIONS_RE = re.compile(
    r"^(?P<pid>\d+)\s+(?P<user>\S+)\s+(?P<group>\S+)\s+"
    r"(?P<machine>\S+)\s+\((?P<ip>[^)]+)\)\s+(?P<proto>\S+)",
    re.MULTILINE,
)


@dataclass(frozen=True, slots=True)
class TimeNestUser:
    username: str
    quota_gb: int
    path: Path
    used_bytes: int
    last_backup_ts: int | None


@dataclass(frozen=True, slots=True)
class SmbSession:
    pid: int
    user: str
    machine: str
    ip: str
    protocol: str


class SambaManager:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    # ------------------------------------------------------------------ users

    async def create_user(self, username: str, password: str, quota_gb: int) -> None:
        self._validate_username(username)
        if quota_gb < 10:
            raise ValueError("quota must be at least 10 GB")
        await self._exec(
            "/usr/local/bin/create-user.sh",
            username,
            password,
            str(quota_gb),
        )

    async def delete_user(self, username: str, purge: bool = False) -> None:
        self._validate_username(username)
        args = ["/usr/local/bin/delete-user.sh", username]
        if purge:
            args.append("--purge")
        await self._exec(*args)

    def list_users(self) -> list[TimeNestUser]:
        shares_dir = self.settings.samba_data_path / ".." / "config" / "shares.d"
        # When the web container mounts `./data/config` as /config we fall
        # back to that path. Keep resolution loose.
        for candidate in (
            shares_dir.resolve(),
            Path("/etc/timenest/shares.d"),
            Path("/config/shares.d"),
            Path("/data/config/shares.d"),
        ):
            if candidate.is_dir():
                shares_dir = candidate
                break
        else:
            return []

        users: list[TimeNestUser] = []
        for conf in shares_dir.glob("*.conf"):
            username = conf.stem
            quota = self._parse_quota(conf)
            user_dir = self.settings.backup_path / username
            used = _dir_size(user_dir) if user_dir.exists() else 0
            last_backup = _last_backup_ts(user_dir)
            users.append(
                TimeNestUser(
                    username=username,
                    quota_gb=quota,
                    path=user_dir,
                    used_bytes=used,
                    last_backup_ts=last_backup,
                )
            )
        users.sort(key=lambda u: u.username)
        return users

    # --------------------------------------------------------------- sessions

    async def list_sessions(self) -> list[SmbSession]:
        try:
            out = await self._exec("smbstatus", "-b")
        except RuntimeError as exc:
            log.warning("smbstatus failed: %s", exc)
            return []
        return [
            SmbSession(
                pid=int(m["pid"]),
                user=m["user"],
                machine=m["machine"],
                ip=m["ip"],
                protocol=m["proto"],
            )
            for m in _SESSIONS_RE.finditer(out)
        ]

    # ----------------------------------------------------------------- helpers

    @staticmethod
    def _validate_username(username: str) -> None:
        if not _USERNAME_RE.match(username):
            raise ValueError(
                "username must match [a-z_][a-z0-9_-]{0,31}"
            )

    @staticmethod
    def _parse_quota(conf: Path) -> int:
        try:
            for line in conf.read_text().splitlines():
                key, _, val = line.strip().partition("=")
                if key.strip() == "fruit:time machine max size":
                    return int(val.strip().rstrip("Gg"))
        except OSError:
            pass
        return 0

    async def _exec(self, *args: str) -> str:
        cmd = [
            "docker",
            "exec",
            "-i",
            self.settings.samba_container,
            *args,
        ]
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        if proc.returncode != 0:
            raise RuntimeError(
                f"{' '.join(cmd[:4])} failed ({proc.returncode}): "
                f"{stderr.decode().strip() or stdout.decode().strip()}"
            )
        return stdout.decode()


def _dir_size(path: Path) -> int:
    total = 0
    try:
        for entry in path.rglob("*"):
            try:
                total += entry.stat().st_size
            except (OSError, FileNotFoundError):
                continue
    except (OSError, PermissionError):
        pass
    return total


def _last_backup_ts(path: Path) -> int | None:
    # Time Machine writes a .com.apple.timemachine.supported file inside
    # the sparsebundle when it finishes a checkpoint. Fall back to the
    # directory mtime if we cannot find one.
    try:
        newest = 0
        for candidate in path.rglob(".com.apple.timemachine.supported"):
            newest = max(newest, int(candidate.stat().st_mtime))
        if newest:
            return newest
        return int(path.stat().st_mtime) if path.exists() else None
    except (OSError, PermissionError):
        return None
