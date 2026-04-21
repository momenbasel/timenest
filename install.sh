#!/usr/bin/env bash
#
# TimeNest one-line installer.
#
#   curl -fsSL https://raw.githubusercontent.com/momenbasel/timenest/main/install.sh | bash
#
# What it does:
#   1. Detects OS and architecture, installs docker + compose if missing
#      (Debian, Ubuntu, Raspberry Pi OS, Fedora, Arch).
#   2. Clones the repo into ~/timenest (or updates an existing clone).
#   3. Walks you through picking a mount path for the backup drive and
#      setting an admin password.
#   4. Writes .env and launches the stack with docker compose up -d.
#
# The script is idempotent: run it again to upgrade an existing install.

set -euo pipefail

BLUE=$'\033[1;34m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; RESET=$'\033[0m'
say()  { printf '%s==>%s %s\n' "$BLUE"  "$RESET" "$*"; }
ok()   { printf '%sok%s  %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!!%s  %s\n' "$YELLOW" "$RESET" "$*"; }
die()  { printf '%sXX%s  %s\n' "$RED"   "$RESET" "$*" >&2; exit 1; }

REPO_URL="${TIMENEST_REPO:-https://github.com/momenbasel/timenest.git}"
INSTALL_DIR="${TIMENEST_DIR:-$HOME/timenest}"

# ---------------------------------------------------------------------------
# Detect platform
# ---------------------------------------------------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)  DOCKER_ARCH=amd64 ;;
    aarch64|arm64) DOCKER_ARCH=arm64 ;;
    armv7l)        DOCKER_ARCH=arm/v7 ;;
    *) die "unsupported architecture: $ARCH" ;;
esac

say "platform: $OS $ARCH ($DOCKER_ARCH)"

# ---------------------------------------------------------------------------
# Ensure docker is present
# ---------------------------------------------------------------------------
ensure_docker_linux() {
    if command -v docker &>/dev/null; then ok "docker already installed"; return; fi
    say "installing docker"
    if   command -v apt-get &>/dev/null; then sudo apt-get update -y && sudo apt-get install -y docker.io docker-compose-plugin git curl
    elif command -v dnf     &>/dev/null; then sudo dnf install -y docker docker-compose-plugin git curl
    elif command -v pacman  &>/dev/null; then sudo pacman -Sy --noconfirm docker docker-compose git curl
    else die "no supported package manager found; install Docker manually from https://docs.docker.com/engine/install/"
    fi
    sudo systemctl enable --now docker || true
    sudo usermod -aG docker "$USER" || true
    warn "added you to the 'docker' group; log out and back in before re-running if the next step fails"
}

ensure_docker_mac() {
    if command -v docker &>/dev/null; then ok "docker already installed"; return; fi
    if command -v brew &>/dev/null; then
        say "installing Docker Desktop via brew"
        brew install --cask docker
        open -a Docker
        warn "Docker Desktop is starting. Re-run this script once it finishes initializing."
        exit 0
    fi
    die "install Docker Desktop from https://www.docker.com/products/docker-desktop/ then re-run"
}

case "$OS" in
    Linux)  ensure_docker_linux ;;
    Darwin) ensure_docker_mac ;;
    *) die "unsupported OS: $OS" ;;
esac

command -v git &>/dev/null || die "git is required; please install it"

# ---------------------------------------------------------------------------
# Clone or update the repo
# ---------------------------------------------------------------------------
if [[ -d "$INSTALL_DIR/.git" ]]; then
    say "updating existing clone at $INSTALL_DIR"
    git -C "$INSTALL_DIR" fetch --tags origin
    git -C "$INSTALL_DIR" pull --ff-only origin main
else
    say "cloning into $INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"

# ---------------------------------------------------------------------------
# Interactive .env setup (skipped when one already exists)
# ---------------------------------------------------------------------------
if [[ -f .env ]]; then
    ok ".env already exists; keeping your current settings"
else
    say "first-time setup"

    printf '\nMount path of the external drive to use for backups:\n'
    printf '   e.g. /mnt/timenest on Linux, /Volumes/Backups on macOS\n'
    read -r -p "> " BACKUP_PATH
    [[ -z "${BACKUP_PATH:-}" ]] && die "backup path is required"
    [[ -d "$BACKUP_PATH" ]] || {
        warn "$BACKUP_PATH does not exist; create it now? [y/N]"
        read -r ans
        [[ "${ans,,}" == y* ]] || die "aborted"
        sudo mkdir -p "$BACKUP_PATH"
    }

    printf '\nAdmin username for the web UI [admin]: '
    read -r ADMIN_USER
    ADMIN_USER="${ADMIN_USER:-admin}"

    printf 'Admin password (leave blank to auto-generate): '
    stty -echo; read -r ADMIN_PASSWORD; stty echo; printf '\n'
    if [[ -z "$ADMIN_PASSWORD" ]]; then
        ADMIN_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9!%^_+-' </dev/urandom | head -c 24)"
        warn "generated admin password: $ADMIN_PASSWORD"
        warn "save it now; the installer will not print it again"
    fi

    printf 'Server name shown in Finder [TimeNest]: '
    read -r SERVER_NAME
    SERVER_NAME="${SERVER_NAME:-TimeNest}"

    cp .env.example .env
    sed -i.bak \
        -e "s|^BACKUP_PATH=.*|BACKUP_PATH=$BACKUP_PATH|" \
        -e "s|^ADMIN_USER=.*|ADMIN_USER=$ADMIN_USER|" \
        -e "s|^ADMIN_PASSWORD=.*|ADMIN_PASSWORD=$ADMIN_PASSWORD|" \
        -e "s|^SERVER_NAME=.*|SERVER_NAME=$SERVER_NAME|" \
        .env
    rm -f .env.bak
    chmod 600 .env
    ok "wrote .env"
fi

# ---------------------------------------------------------------------------
# Launch
# ---------------------------------------------------------------------------
say "pulling images and starting the stack (this takes a minute the first time)"
docker compose pull --ignore-pull-failures || true
docker compose up -d --build

ok "TimeNest is running"
HOST="$(hostname -s 2>/dev/null || hostname)"
printf '\nOpen the admin UI:  %shttp://%s.local:8080%s\n' "$GREEN" "$HOST" "$RESET"
printf 'On your Mac:        System Settings -> General -> Time Machine -> Add Backup Disk\n'
printf '                    Look for the share named: %s%s%s\n\n' "$GREEN" "$(grep -E '^SERVER_NAME=' .env | cut -d= -f2)" "$RESET"
