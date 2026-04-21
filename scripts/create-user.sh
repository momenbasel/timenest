#!/usr/bin/env bash
#
# Create a Time Machine user and a matching per-user Samba share fragment.
#
# Usage:
#   create-user.sh <username> <password> <quota_gb>
#
# Called by the web UI via `docker exec timenest-samba`. Idempotent: if the
# user already exists the password is rotated and the quota updated.

set -euo pipefail

log() { printf '[create-user] %s\n' "$*"; }
die() { printf '[create-user] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ $# -ne 3 ]]; then
    die "usage: $0 <username> <password> <quota_gb>"
fi

USERNAME="$1"
PASSWORD="$2"
QUOTA_GB="$3"

# Username must be POSIX-safe and non-conflicting with system accounts.
if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    die "invalid username: must match [a-z_][a-z0-9_-]{0,31}"
fi
if [[ ! "$QUOTA_GB" =~ ^[0-9]+$ ]] || (( QUOTA_GB < 10 )); then
    die "invalid quota: must be an integer >= 10 (GB)"
fi

USER_DIR="/backup/${USERNAME}"
SHARE_CONF="/etc/timenest/shares.d/${USERNAME}.conf"

# System user creation is required so Samba's `valid users = ${USERNAME}`
# resolves. No shell, no home dir outside /backup.
if ! id "$USERNAME" &>/dev/null; then
    log "creating POSIX user '${USERNAME}'"
    useradd --system --no-create-home --shell /usr/sbin/nologin "$USERNAME"
fi

# smbpasswd -a is idempotent; -x removes.
log "setting Samba password for '${USERNAME}'"
( echo "$PASSWORD"; echo "$PASSWORD" ) | smbpasswd -s -a "$USERNAME"

mkdir -p "$USER_DIR"
chown "${USERNAME}:${USERNAME}" "$USER_DIR"
chmod 0700 "$USER_DIR"

# Render share fragment. The TM max-size parameter is what Samba reports
# back to macOS as available space for backups; the filesystem itself is
# not actually quota-enforced unless you enabled ext4 project quotas on
# the host. We rely on fruit's cap instead, which Time Machine respects.
cat > "$SHARE_CONF" <<EOF
[${USERNAME}]
    comment = TimeNest Time Machine target for ${USERNAME}
    path = /backup/${USERNAME}
    valid users = ${USERNAME}
    force user = ${USERNAME}
    force group = ${USERNAME}
    read only = no
    browseable = yes
    inherit acls = yes
    inherit permissions = yes
    create mask = 0600
    directory mask = 0700
    ea support = yes
    kernel oplocks = no
    kernel share modes = no
    posix locking = no
    durable handles = yes
    vfs objects = catia fruit streams_xattr
    fruit:time machine = yes
    fruit:time machine max size = ${QUOTA_GB}G
EOF

log "wrote ${SHARE_CONF} (quota ${QUOTA_GB}G)"

# Reload Samba in place (SIGHUP). No restart required.
if pidof smbd >/dev/null; then
    log "reloading smbd"
    pkill -HUP smbd || true
fi

log "done"
