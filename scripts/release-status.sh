#!/usr/bin/env bash
#
# Print TimeNest release-pipeline readiness from the maintainer's Mac.
# Exits 0 if a release tag can be cut today, non-zero if anything blocks.

set -u

GREEN=$'\033[1;32m'; RED=$'\033[1;31m'; YEL=$'\033[1;33m'; RESET=$'\033[0m'
ok()    { printf '  %sok%s   %s\n' "$GREEN" "$RESET" "$*"; }
miss()  { printf '  %sxx%s   %s\n' "$RED"   "$RESET" "$*"; FAIL=1; }
warn()  { printf '  %s!!%s   %s\n' "$YEL"   "$RESET" "$*"; }
hdr()   { printf '\n%s\n' "$*"; }

FAIL=0

hdr "github tap repo"
if gh repo view momenbasel/homebrew-timenest --json url >/dev/null 2>&1; then
    ok "momenbasel/homebrew-timenest exists"
else
    miss "tap repo missing; create with: gh repo create momenbasel/homebrew-timenest --public"
fi

hdr "self-hosted runner"
if gh api repos/momenbasel/timenest/actions/runners --jq '.runners[] | select(.labels[].name == "timenest-release") | .status' 2>/dev/null | grep -qx online; then
    ok "runner with label 'timenest-release' is online"
else
    miss "runner offline or missing label 'timenest-release'"
fi

hdr "Apple signing identities"
INSTALLER_LINE=$(security find-identity -v -p basic 2>/dev/null | grep "Developer ID Installer" || true)
APP_LINE=$(security find-identity -v -p basic 2>/dev/null | grep "Developer ID Application" || true)
if [ -n "$APP_LINE" ]; then
    ok "Developer ID Application: $(echo "$APP_LINE" | sed -E 's/.*"(.*)".*/\1/')"
else
    warn "Developer ID Application missing (not strictly required for .pkg, but expected)"
fi
if [ -n "$INSTALLER_LINE" ]; then
    ok "Developer ID Installer:   $(echo "$INSTALLER_LINE" | sed -E 's/.*"(.*)".*/\1/')"
else
    miss "Developer ID Installer missing - request at https://developer.apple.com/account/resources/certificates/add using ~/.timenest-release-bootstrap/timenest-installer.csr"
fi

hdr "notarytool keychain profile"
if xcrun notarytool history --keychain-profile AC_NOTARY >/dev/null 2>&1; then
    ok "AC_NOTARY profile present and valid"
else
    miss "AC_NOTARY profile missing - run: xcrun notarytool store-credentials AC_NOTARY --key ~/.appstoreconnect/private_keys/AuthKey_5G7R52L8RK.p8 --key-id 5G7R52L8RK --issuer 5de3898a-cd31-4061-850f-ae17b389e46a"
fi

hdr "runner environment file"
ENV_FILE="$HOME/actions-runner-timenest/.env"
if [ -f "$ENV_FILE" ]; then
    if grep -q '^TIMENEST_SIGN_IDENTITY=.\+' "$ENV_FILE"; then
        ok "TIMENEST_SIGN_IDENTITY populated"
    else
        miss "TIMENEST_SIGN_IDENTITY empty in $ENV_FILE - paste your Developer ID Installer identity"
    fi
    if grep -q '^TIMENEST_NOTARY_PROFILE=.\+' "$ENV_FILE"; then
        ok "TIMENEST_NOTARY_PROFILE populated"
    else
        miss "TIMENEST_NOTARY_PROFILE empty in $ENV_FILE"
    fi
else
    miss "runner .env missing: $ENV_FILE"
fi

hdr "gh CLI"
if gh auth status >/dev/null 2>&1; then
    scopes=$(gh auth status 2>&1 | grep -oE "Token scopes: '[^']+'" | head -1)
    ok "gh logged in (${scopes:-scopes unknown})"
else
    miss "gh CLI not authenticated; run 'gh auth login'"
fi

hdr "docker images already signed (latest)"
for img in samba avahi web; do
    if cosign verify "ghcr.io/momenbasel/timenest-${img}:latest" \
        --certificate-identity-regexp 'https://github.com/momenbasel/timenest/' \
        --certificate-oidc-issuer https://token.actions.githubusercontent.com \
        >/dev/null 2>&1; then
        ok "ghcr.io/momenbasel/timenest-${img}:latest cosign signature valid"
    else
        warn "ghcr.io/momenbasel/timenest-${img}:latest unsigned or not pushed yet"
    fi
done

echo
if [ "$FAIL" = "0" ]; then
    printf '%sREADY%s - you can git tag -a vX.Y.Z and git push origin vX.Y.Z\n' "$GREEN" "$RESET"
    exit 0
else
    printf '%sBLOCKED%s - fix the items marked xx above before tagging\n' "$RED" "$RESET"
    exit 1
fi
