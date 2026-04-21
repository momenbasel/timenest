"""Disk usage and SMART health for the admin dashboard."""

from __future__ import annotations

import asyncio
import json
import logging
import subprocess
from dataclasses import dataclass
from pathlib import Path

import psutil

log = logging.getLogger(__name__)


@dataclass(frozen=True, slots=True)
class DiskUsage:
    mount: str
    total_bytes: int
    used_bytes: int
    free_bytes: int
    percent: float


@dataclass(frozen=True, slots=True)
class SmartStatus:
    device: str
    model: str
    serial: str
    healthy: bool
    temperature_c: int | None
    power_on_hours: int | None
    hours_until_replace_est: int | None


def usage(mount: Path | str) -> DiskUsage | None:
    try:
        s = psutil.disk_usage(str(mount))
    except (FileNotFoundError, PermissionError):
        return None
    return DiskUsage(
        mount=str(mount),
        total_bytes=s.total,
        used_bytes=s.used,
        free_bytes=s.free,
        percent=s.percent,
    )


async def smart(device: str) -> SmartStatus | None:
    """Run smartctl and parse the JSON output. Returns None if unavailable."""
    proc = await asyncio.create_subprocess_exec(
        "smartctl",
        "-a",
        "-j",
        device,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = await proc.communicate()
    if proc.returncode not in (0, 2, 4):
        # smartctl uses bitmask exit codes; 2 = "opened read-only", 4 =
        # "some SMART commands failed" - both still yield parseable JSON.
        log.debug("smartctl %s exited %d: %s", device, proc.returncode, stderr)
        return None
    try:
        data = json.loads(stdout)
    except json.JSONDecodeError:
        return None

    healthy = data.get("smart_status", {}).get("passed", False)
    temp = data.get("temperature", {}).get("current")
    poh = data.get("power_on_time", {}).get("hours")
    return SmartStatus(
        device=device,
        model=data.get("model_name", "unknown"),
        serial=data.get("serial_number", "unknown"),
        healthy=bool(healthy),
        temperature_c=temp,
        power_on_hours=poh,
        hours_until_replace_est=_estimate_replace_hours(data),
    )


def _estimate_replace_hours(data: dict) -> int | None:
    # Very rough: if the drive is an SSD with a percent-used attribute,
    # linearly extrapolate remaining life from power-on hours.
    attrs = data.get("ata_smart_attributes", {}).get("table", []) or []
    poh = data.get("power_on_time", {}).get("hours")
    if not poh:
        return None
    for attr in attrs:
        if attr.get("name") in ("Percent_Lifetime_Remain", "Wear_Leveling_Count"):
            raw = attr.get("value")
            if isinstance(raw, int) and 0 < raw <= 100:
                used_pct = 100 - raw
                if used_pct <= 0:
                    return None
                return int(poh * (100 - used_pct) / used_pct)
    return None
