# Security policy

## Supported versions

| Version | Supported |
| ------- | :-------: |
| 0.1.x   | Yes       |
| < 0.1   | No        |

## Reporting a vulnerability

Do **not** open a public issue for a security problem. Instead:

- Preferred: GitHub Security Advisories - https://github.com/momenbasel/timenest/security/advisories/new
- Email: ceo@greycorelabs.com with subject `[TimeNest security] <short>`
- PGP is available on request.

Please include, at minimum:

- Affected version or commit hash.
- Proof-of-concept: request, payload, or script.
- Impact: what an attacker can do.

## Response time

- First response within **72 hours**.
- Triage + fix plan within **7 days** of triage.
- Coordinated disclosure: 90 days by default, shorter if actively exploited.

## Scope

In scope:

- The Samba, Avahi, and FastAPI containers published at `ghcr.io/momenbasel/timenest-*`.
- The installer script and the rendered `smb.conf`.
- The web UI (`:8080`) and its session handling.

Out of scope:

- Bugs in upstream Samba, Avahi, Debian packages, Docker itself. Report those upstream.
- Physical attacks on the host.
- Issues requiring admin access to the host OS already.

## Safe harbour

Good-faith research, no data destruction, no pivot to hosts you do not own, no attempts to degrade service for other users. If you follow that, I will not pursue legal action and will credit you in the advisory if you want.
