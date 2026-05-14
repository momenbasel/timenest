#!/usr/bin/env bash
#
# TimeNest - Avahi entrypoint
#
# Renders the Bonjour service XML from env vars and launches avahi-daemon
# in the foreground. Because this runs in host network mode, advertisement
# reaches the LAN directly without NAT.

set -euo pipefail

log() { printf '[avahi] %s\n' "$*"; }
die() { printf '[avahi] ERROR: %s\n' "$*" >&2; exit 1; }

: "${SERVER_NAME:=TimeNest}"
: "${DEVICE_MODEL:=TimeCapsule8,119}"
export SERVER_NAME DEVICE_MODEL

mkdir -p /etc/avahi/services

# shellcheck disable=SC2016  # single quotes intentional; envsubst reads literal ${VAR} list
envsubst '${SERVER_NAME} ${DEVICE_MODEL}' \
    < /etc/timenest/timenest.service.template \
    > /etc/avahi/services/timenest.service

# Strip out any pre-existing stock services so we don't double-advertise.
rm -f /etc/avahi/services/*.service.dpkg-* 2>/dev/null || true
for f in /etc/avahi/services/*.service; do
    case "$(basename "$f")" in
        timenest.service) : ;;
        *) rm -f "$f" ;;
    esac
done

log "rendered /etc/avahi/services/timenest.service"
log "advertising '${SERVER_NAME}' as model '${DEVICE_MODEL}'"

shutdown() {
    log "received shutdown signal, stopping avahi-daemon"
    kill -TERM "${AVAHI_PID:-0}" 2>/dev/null || true
    wait "${AVAHI_PID:-0}" 2>/dev/null || true
    exit 0
}
trap shutdown TERM INT

# --no-drop-root is required when running as pid 1 inside a minimal
# container. --no-rlimits because tini+container already bounds us.
exec avahi-daemon \
    --no-drop-root \
    --no-rlimits \
    --file=/etc/avahi/avahi-daemon.conf
