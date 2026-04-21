#!/usr/bin/env bash
#
# TimeNest - Samba entrypoint
#
# Renders /etc/samba/smb.conf from the template, seeds the passdb and the
# shares directory if this is a fresh install, then starts smbd in the
# foreground so tini can reap it.

set -euo pipefail

log() { printf '[samba] %s\n' "$*"; }
die() { printf '[samba] ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Env defaults
# ---------------------------------------------------------------------------
: "${SERVER_NAME:=TimeNest}"
: "${DEVICE_MODEL:=TimeCapsule8,119}"
: "${SMB_INTERFACES:=}"
: "${LOG_LEVEL:=INFO}"

# Map human log levels to Samba's numeric scale.
case "${LOG_LEVEL^^}" in
    DEBUG)   SAMBA_LOG_LEVEL=3 ;;
    INFO)    SAMBA_LOG_LEVEL=1 ;;
    WARNING) SAMBA_LOG_LEVEL=1 ;;
    ERROR)   SAMBA_LOG_LEVEL=0 ;;
    *)       SAMBA_LOG_LEVEL=1 ;;
esac
export SAMBA_LOG_LEVEL

# `bind interfaces only` makes sense only when interfaces are given.
if [[ -n "$SMB_INTERFACES" ]]; then
    BIND_INTERFACES_ONLY=yes
else
    BIND_INTERFACES_ONLY=no
    SMB_INTERFACES=""
fi
export BIND_INTERFACES_ONLY SMB_INTERFACES
export SERVER_NAME DEVICE_MODEL

# ---------------------------------------------------------------------------
# Filesystem layout
# ---------------------------------------------------------------------------
mkdir -p /etc/samba /etc/timenest/shares.d /var/lib/samba/private /var/log/samba /backup

# The template uses ${VAR} syntax - envsubst only replaces explicitly
# listed vars to avoid accidentally eating literal `$` in comments.
envsubst '${SERVER_NAME} ${DEVICE_MODEL} ${SMB_INTERFACES} ${BIND_INTERFACES_ONLY} ${SAMBA_LOG_LEVEL}' \
    < /etc/timenest/smb.conf.template \
    > /etc/samba/smb.conf

log "rendered /etc/samba/smb.conf"
log "backing up to /backup (host BACKUP_PATH)"
log "advertising as '${SERVER_NAME}' / model '${DEVICE_MODEL}'"

# ---------------------------------------------------------------------------
# Seed passdb on first boot so `net` commands do not complain.
# ---------------------------------------------------------------------------
if [[ ! -s /var/lib/samba/passdb.tdb ]]; then
    log "initializing fresh passdb"
    touch /var/lib/samba/smbpasswd
fi

# Verify the config parses before we exec smbd. A bad template means no
# restart loop panic - we fail fast with a readable error.
if ! testparm -s /etc/samba/smb.conf > /dev/null 2>&1; then
    log "testparm output:"
    testparm -s /etc/samba/smb.conf || true
    die "smb.conf failed to parse; refusing to start"
fi

# ---------------------------------------------------------------------------
# Handle SIGTERM cleanly - smbd's default is graceful on SIGTERM.
# ---------------------------------------------------------------------------
shutdown() {
    log "received shutdown signal, stopping smbd"
    kill -TERM "${SMBD_PID:-0}" 2>/dev/null || true
    wait "${SMBD_PID:-0}" 2>/dev/null || true
    exit 0
}
trap shutdown TERM INT

log "starting smbd (foreground)"
smbd --foreground --log-stdout --no-process-group --configfile=/etc/samba/smb.conf &
SMBD_PID=$!

wait "$SMBD_PID"
