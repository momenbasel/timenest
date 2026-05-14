#!/usr/bin/env bash
#
# Build a macOS .pkg installer that places the TimeNest CLI + compose
# stack under /usr/local/timenest and symlinks /usr/local/bin/timenest.
#
# Reproducible locally and from CI. Codesigning + notarization happen
# in the release workflow; this script just produces the unsigned .pkg.
#
# Usage:
#   scripts/build-pkg.sh <version>
#
# Output:
#   dist/TimeNest-<version>.pkg

set -euo pipefail

VERSION="${1:?usage: build-pkg.sh <version>}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${REPO_ROOT}/build/pkg"
DIST="${REPO_ROOT}/dist"
ROOT="${BUILD}/root"
SCRIPTS="${BUILD}/scripts"
PREFIX="/usr/local/timenest"

PKG_ID="${PKG_ID:-com.greycorelabs.timenest}"

rm -rf "$BUILD" "$DIST/TimeNest-${VERSION}.pkg"
mkdir -p "${ROOT}${PREFIX}" "${ROOT}/usr/local/bin" "${SCRIPTS}" "${DIST}"

# ---------------------------------------------------------------------------
# Stage payload
# ---------------------------------------------------------------------------
cp "${REPO_ROOT}/docker-compose.yml" "${ROOT}${PREFIX}/docker-compose.yml"
cp "${REPO_ROOT}/.env.example"       "${ROOT}${PREFIX}/.env.example"
cp "${REPO_ROOT}/install.sh"         "${ROOT}${PREFIX}/install.sh"
cp -R "${REPO_ROOT}/samba"           "${ROOT}${PREFIX}/samba"
cp -R "${REPO_ROOT}/avahi"           "${ROOT}${PREFIX}/avahi"
cp -R "${REPO_ROOT}/scripts"         "${ROOT}${PREFIX}/scripts"
cp -R "${REPO_ROOT}/web"             "${ROOT}${PREFIX}/web"
printf '%s\n' "$VERSION" > "${ROOT}${PREFIX}/.version"

# CLI wrapper, rewritten so TIMENEST_HOME points at the pkg install dir.
# shellcheck disable=SC2016  # single-quoted pattern intentional; we want literal $ in sed match
sed 's|TIMENEST_HOME="\${TIMENEST_HOME:-\$HOME/timenest}"|TIMENEST_HOME="${TIMENEST_HOME:-'"${PREFIX}"'}"|' \
    "${REPO_ROOT}/bin/timenest" > "${ROOT}/usr/local/bin/timenest"
chmod 0755 "${ROOT}/usr/local/bin/timenest"

# ---------------------------------------------------------------------------
# postinstall: chmod helpers, create launchd plist optionally
# ---------------------------------------------------------------------------
cat > "${SCRIPTS}/postinstall" <<'POST'
#!/bin/bash
set -e
chmod 0755 /usr/local/timenest/install.sh
chmod 0755 /usr/local/timenest/scripts/*.sh
exit 0
POST
chmod 0755 "${SCRIPTS}/postinstall"

# ---------------------------------------------------------------------------
# Component + product pkg
# ---------------------------------------------------------------------------
COMPONENT="${BUILD}/TimeNest-component.pkg"
pkgbuild \
    --root "${ROOT}" \
    --identifier "${PKG_ID}" \
    --version "${VERSION}" \
    --scripts "${SCRIPTS}" \
    --install-location "/" \
    "${COMPONENT}"

cat > "${BUILD}/distribution.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>TimeNest</title>
    <organization>com.greycorelabs</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="false" rootVolumeOnly="true" hostArchitectures="x86_64,arm64"/>
    <pkg-ref id="${PKG_ID}"/>
    <choices-outline>
        <line choice="default">
            <line choice="${PKG_ID}"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="${PKG_ID}" visible="false">
        <pkg-ref id="${PKG_ID}"/>
    </choice>
    <pkg-ref id="${PKG_ID}" version="${VERSION}" onConclusion="none">TimeNest-component.pkg</pkg-ref>
</installer-gui-script>
XML

productbuild \
    --distribution "${BUILD}/distribution.xml" \
    --package-path "${BUILD}" \
    --version "${VERSION}" \
    "${DIST}/TimeNest-${VERSION}.pkg"

echo "built ${DIST}/TimeNest-${VERSION}.pkg"
