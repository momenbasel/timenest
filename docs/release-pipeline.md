# TimeNest release pipeline

Triggered by pushing a `v*` tag (or via `workflow_dispatch`). One tag push
produces:

| Artifact                                      | Workflow              | Signing |
|-----------------------------------------------|-----------------------|---------|
| `ghcr.io/momenbasel/timenest-{samba,avahi,web}` multi-arch images | `docker.yml`     | cosign keyless (GitHub OIDC) |
| `dist/TimeNest-<version>.pkg` (macOS installer)                   | `release.yml`    | Developer ID Installer + notarytool staple |
| GitHub release with `.pkg` attached                               | `release.yml`    | - |
| `momenbasel/homebrew-timenest` formula bump commit                | `release.yml`    | - |

## Required repository secrets

| Secret                                       | Purpose |
|----------------------------------------------|---------|
| `APPLE_DEVELOPER_ID_INSTALLER_CERT_BASE64`   | `base64 < DeveloperIDInstaller.p12` of the exported "Developer ID Installer" certificate. |
| `APPLE_DEVELOPER_ID_INSTALLER_CERT_PASSWORD` | Password used when exporting the .p12 above. |
| `APPLE_DEVELOPER_ID_INSTALLER_IDENTITY`      | Exact identity string, e.g. `Developer ID Installer: Greycore Labs (TEAMID12)`. |
| `APPLE_KEYCHAIN_PASSWORD`                    | Throwaway password the runner uses to create + unlock the build keychain. |
| `APPLE_ID`                                   | Apple Developer account email. |
| `APPLE_TEAM_ID`                              | 10-character Team ID from the Developer portal. |
| `APPLE_NOTARY_PASSWORD`                      | App-specific password generated at appleid.apple.com (NOT your Apple ID password). |
| `HOMEBREW_TAP_TOKEN`                         | Fine-grained PAT with `Contents: read/write` on `momenbasel/homebrew-timenest`. |

`cosign` itself needs no secrets - the docker workflow already requests
`id-token: write` and signs against the public Sigstore Fulcio root
using GitHub's OIDC token.

## One-time bootstrap

1. **Create the tap repo.** `gh repo create momenbasel/homebrew-timenest --public --description "Homebrew tap for TimeNest"` then push an initial commit containing only `README.md`. The release workflow writes `Formula/timenest.rb` on first run.
2. **Generate the Apple cert.** In Xcode > Settings > Accounts, request a "Developer ID Installer" certificate. Export it to `.p12` with a password. `base64 < cert.p12 | pbcopy` and paste into `APPLE_DEVELOPER_ID_INSTALLER_CERT_BASE64`.
3. **App-specific password.** Sign in at appleid.apple.com > Sign-In and Security > App-Specific Passwords > Generate. Label it `timenest-notary`. This is `APPLE_NOTARY_PASSWORD`.
4. **PAT for the tap.** github.com > Settings > Developer settings > Fine-grained tokens > Generate. Scope it to the `homebrew-timenest` repo with `Contents: read and write`. Paste into `HOMEBREW_TAP_TOKEN`.

## Cutting a release

```
git tag -a v0.2.0 -m "v0.2.0"
git push origin v0.2.0
```

That fires:

1. `docker.yml` - builds + signs all three images for the new tag.
2. `release.yml` - builds, signs, and notarizes the `.pkg`; computes the tarball SHA; publishes the GitHub release with the `.pkg` attached; pushes a formula-bump commit to the tap.

## Verifying the artifacts

```bash
# Verify a Docker image's cosign signature
cosign verify ghcr.io/momenbasel/timenest-web:v0.2.0 \
    --certificate-identity-regexp 'https://github.com/momenbasel/timenest/' \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com

# Verify the macOS installer's signature + notarization
pkgutil --check-signature dist/TimeNest-0.2.0.pkg
spctl --assess --type install --verbose dist/TimeNest-0.2.0.pkg

# Verify the Homebrew install path
brew tap momenbasel/timenest
brew install --formula timenest
timenest version
```

## Local repro of the .pkg build

```bash
scripts/build-pkg.sh 0.2.0
# Output: dist/TimeNest-0.2.0.pkg  (unsigned)
```

The codesign + notarize steps live in `release.yml` only; running them
locally requires the same secrets installed in your keychain.
