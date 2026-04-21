#!/usr/bin/env bash
#
# Remove a TimeNest user. Does NOT delete backup data by default; pass
# --purge to wipe the user's backup directory too.
#
# Usage:
#   delete-user.sh <username> [--purge]

set -euo pipefail

log() { printf '[delete-user] %s\n' "$*"; }
die() { printf '[delete-user] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ $# -lt 1 || $# -gt 2 ]]; then
    die "usage: $0 <username> [--purge]"
fi

USERNAME="$1"
PURGE="${2:-}"

if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    die "invalid username"
fi

SHARE_CONF="/etc/timenest/shares.d/${USERNAME}.conf"
USER_DIR="/backup/${USERNAME}"

if id "$USERNAME" &>/dev/null; then
    log "removing Samba password for '${USERNAME}'"
    smbpasswd -x "$USERNAME" || true
    log "removing POSIX user '${USERNAME}'"
    userdel "$USERNAME" || true
fi

rm -f "$SHARE_CONF"
log "removed ${SHARE_CONF}"

if [[ "$PURGE" == "--purge" ]]; then
    log "purging backup directory (${USER_DIR})"
    rm -rf -- "$USER_DIR"
else
    log "leaving backup data at ${USER_DIR} untouched (pass --purge to wipe)"
fi

if pidof smbd >/dev/null; then
    pkill -HUP smbd || true
fi

log "done"
