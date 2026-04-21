"""Prometheus metrics exposition.

Kept deliberately lightweight: a small set of gauges that tell you whether
backups are happening and whether the drive is about to fill.
"""

from __future__ import annotations

from prometheus_client import CollectorRegistry, Gauge, generate_latest

from . import disks, samba_mgr
from .config import Settings

CONTENT_TYPE = "text/plain; version=0.0.4; charset=utf-8"


async def render(settings: Settings, mgr: samba_mgr.SambaManager) -> bytes:
    registry = CollectorRegistry()

    users_gauge = Gauge(
        "timenest_users_total",
        "Total configured TimeNest users",
        registry=registry,
    )
    sessions_gauge = Gauge(
        "timenest_sessions_active",
        "Active SMB sessions",
        registry=registry,
    )
    used_gauge = Gauge(
        "timenest_backup_bytes_used",
        "Bytes used by a user's backup directory",
        labelnames=("user",),
        registry=registry,
    )
    quota_gauge = Gauge(
        "timenest_backup_quota_bytes",
        "Configured Time Machine quota in bytes",
        labelnames=("user",),
        registry=registry,
    )
    last_backup_gauge = Gauge(
        "timenest_last_backup_timestamp_seconds",
        "Unix timestamp of the most recent backup checkpoint",
        labelnames=("user",),
        registry=registry,
    )
    disk_total_gauge = Gauge(
        "timenest_disk_total_bytes",
        "Total bytes on the backup volume",
        labelnames=("mount",),
        registry=registry,
    )
    disk_free_gauge = Gauge(
        "timenest_disk_free_bytes",
        "Free bytes on the backup volume",
        labelnames=("mount",),
        registry=registry,
    )

    users = mgr.list_users()
    users_gauge.set(len(users))

    sessions = await mgr.list_sessions()
    sessions_gauge.set(len(sessions))

    for u in users:
        used_gauge.labels(user=u.username).set(u.used_bytes)
        quota_gauge.labels(user=u.username).set(u.quota_gb * 1024**3)
        if u.last_backup_ts:
            last_backup_gauge.labels(user=u.username).set(u.last_backup_ts)

    du = disks.usage(settings.backup_path)
    if du:
        disk_total_gauge.labels(mount=du.mount).set(du.total_bytes)
        disk_free_gauge.labels(mount=du.mount).set(du.free_bytes)

    return generate_latest(registry)
