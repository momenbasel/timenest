# TimeNest release pipeline

Triggered by pushing a `v*` tag (or via `workflow_dispatch`). One tag push
produces:

| Artifact                                                          | Where it runs     | Signing |
|-------------------------------------------------------------------|-------------------|---------|
| `ghcr.io/momenbasel/timenest-{samba,avahi,web}` multi-arch images | github-hosted     | cosign keyless (GitHub OIDC, no secrets) |
| `dist/TimeNest-<version>.pkg` (macOS installer)                   | **self-hosted Mac** | Developer ID Installer + notarytool staple |
| GitHub release with `.pkg` attached                               | github-hosted     | - |
| `momenbasel/homebrew-timenest` formula bump commit                | **self-hosted Mac** | - |

**No signing secrets ever live in GitHub.** The Apple cert + notary
credentials + tap PAT all live in the self-hosted runner's local
keychain and `.env`. Repo secrets are not used by `release.yml` for
anything sensitive.

## Why self-hosted

This repo is public. Storing the Apple Developer ID certificate,
app-specific notary password, or a PAT in GitHub Actions secrets would
expose them via any workflow_run with malicious code (eg. a compromised
third-party action). Running the signing job on a personal Mac removes
that blast radius entirely. The github-hosted jobs (`tarball-hash`,
`publish-release`, image build + cosign) never touch the sensitive
material.

The runner is registered for tag-triggered workflows only - PRs cannot
reach it. PRs from forks never receive secrets nor self-hosted runners
on GitHub by default.

## One-time bootstrap on the Mac runner

State of this machine, recorded for reference:

| Component                       | Status                                          |
|---------------------------------|-------------------------------------------------|
| Tap repo `momenbasel/homebrew-timenest` | created (public, seeded with Formula)   |
| Self-hosted runner              | registered + launchd service installed, online  |
| `Developer ID Application` cert | present in login keychain                        |
| `Developer ID Installer` cert   | **NOT YET ISSUED** - see step 1                  |
| notarytool keychain profile     | `AC_NOTARY` already exists (ASC API key based)  |
| App Store Connect API key       | `~/.appstoreconnect/private_keys/AuthKey_5G7R52L8RK.p8` |

### 1. Apple `Developer ID Installer` certificate (the only manual step)

`productsign` requires this specific cert type. Apple's App Store
Connect API does NOT expose certificate creation for the Developer ID
Installer variant - only the Application and Kext variants - so this is
the one step that has to happen in a browser.

A CSR has already been generated and is waiting at
`~/.timenest-release-bootstrap/timenest-installer.csr`. To finish:

1. Sign in at <https://developer.apple.com/account/resources/certificates/add>
2. Choose certificate type **Developer ID Installer**
3. Upload the CSR file above
4. Download the resulting `.cer` and double-click to install in the
   login keychain
5. Verify: `security find-identity -v -p basic | grep "Developer ID Installer"`
6. Copy the identity string and put it in the runner `.env` (step 4)

The matching private key lives at
`~/.timenest-release-bootstrap/timenest-installer.key` - keep it next
to the keychain in case the keychain entry is ever rebuilt.

### 2. Notary keychain profile

Already done on this machine: profile `AC_NOTARY` was created with the
App Store Connect API key. Verify with:

```bash
xcrun notarytool history --keychain-profile AC_NOTARY | head
```

To create a fresh TimeNest-scoped profile instead (optional, the
existing one already works):

```bash
xcrun notarytool store-credentials timenest-notary \
    --key      ~/.appstoreconnect/private_keys/AuthKey_5G7R52L8RK.p8 \
    --key-id   5G7R52L8RK \
    --issuer   5de3898a-cd31-4061-850f-ae17b389e46a
```

### 3. Tap PAT

Generate a fine-grained PAT at
<https://github.com/settings/tokens?type=beta> scoped to repo
`momenbasel/homebrew-timenest` with `Contents: Read and write`. Paste it
into `~/actions-runner-timenest/.env` as `TIMENEST_TAP_TOKEN=...`.

### 4. Wire runner env

Edit `~/actions-runner-timenest/.env`:

```env
TIMENEST_SIGN_IDENTITY=Developer ID Installer: Moamen Basel (H3WXHVTP97)
TIMENEST_NOTARY_PROFILE=AC_NOTARY
TIMENEST_TAP_TOKEN=github_pat_...
```

Then restart the runner service so it picks up the new env:

```bash
cd ~/actions-runner-timenest && ./svc.sh stop && ./svc.sh start
```

### 5. Runner status

```bash
gh api repos/momenbasel/timenest/actions/runners --jq '.runners[]'
# Should show status: online with labels self-hosted,macOS,ARM64,timenest-release
```

## Cutting a release

```bash
git tag -a v0.2.0 -m "v0.2.0"
git push origin v0.2.0
```

That fires:

1. `docker.yml` (github-hosted) - builds + cosign-signs all three images.
2. `release.yml`:
   - `macos-pkg` (self-hosted) - builds, signs, notarizes, staples the `.pkg`.
   - `tarball-hash` (github-hosted) - SHA-256s the source tarball.
   - `publish-release` (github-hosted) - creates the GitHub release with `.pkg` attached.
   - `bump-tap` (self-hosted) - pushes a formula bump commit to the tap.

## Verifying the artifacts

```bash
# Docker image cosign signature
cosign verify ghcr.io/momenbasel/timenest-web:v0.2.0 \
    --certificate-identity-regexp 'https://github.com/momenbasel/timenest/' \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com

# .pkg signature + notarization staple
pkgutil --check-signature dist/TimeNest-0.2.0.pkg
spctl --assess --type install --verbose dist/TimeNest-0.2.0.pkg

# Homebrew install path
brew tap momenbasel/timenest
brew install --formula timenest
timenest version
```

## Local repro of the .pkg build (unsigned)

```bash
scripts/build-pkg.sh 0.2.0
# Output: dist/TimeNest-0.2.0.pkg  (unsigned)
```

To sign + notarize locally (requires the same env vars set):

```bash
productsign --sign "$TIMENEST_SIGN_IDENTITY" \
    dist/TimeNest-0.2.0.pkg dist/TimeNest-0.2.0-signed.pkg
xcrun notarytool submit dist/TimeNest-0.2.0-signed.pkg \
    --keychain-profile "$TIMENEST_NOTARY_PROFILE" --wait
xcrun stapler staple dist/TimeNest-0.2.0-signed.pkg
```
