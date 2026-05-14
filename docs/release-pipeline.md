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

### 1. Apple certificates

```bash
security find-identity -v -p basic | grep "Developer ID"
```

You need **`Developer ID Installer`** (productsign for `.pkg`). If you
only see `Developer ID Application`, request the Installer cert here:
<https://developer.apple.com/account/resources/certificates/list>
(certificate type "Developer ID Installer"). Generate a CSR with Keychain
Access > Certificate Assistant, upload it, download + double-click to
install in your login keychain.

### 2. Notary keychain profile

Generate an app-specific password at
<https://appleid.apple.com/account/manage> > Sign-In and Security >
App-Specific Passwords. Label it `timenest-notary`. Then:

```bash
xcrun notarytool store-credentials timenest-notary \
    --apple-id "<your@apple.id>" \
    --team-id  "H3WXHVTP97" \
    --password "<app-specific-password>"
```

The password is now stored encrypted in the login keychain. The runner
reads it only when notarytool is invoked.

### 3. Tap PAT

Generate a fine-grained PAT at
<https://github.com/settings/tokens?type=beta> scoped to repo
`momenbasel/homebrew-timenest` with `Contents: Read and write`. Paste it
into `~/actions-runner-timenest/.env` as `TIMENEST_TAP_TOKEN=...`.

### 4. Wire runner env

Edit `~/actions-runner-timenest/.env`:

```env
TIMENEST_SIGN_IDENTITY=Developer ID Installer: Moamen Basel (H3WXHVTP97)
TIMENEST_NOTARY_PROFILE=timenest-notary
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
