# Contributing

Thanks for considering a contribution. TimeNest is meant to stay small, sharp, and dependency-light - contributions that align with that are very welcome; contributions that add surface area need a strong justification.

## Development setup

```bash
git clone https://github.com/momenbasel/timenest.git
cd timenest
cp .env.example .env
# edit .env so ADMIN_PASSWORD is set and BACKUP_PATH points at a scratch dir
docker compose up --build
```

For web-only work (no real SMB needed) you can run the FastAPI app directly:

```bash
cd web
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export ADMIN_PASSWORD=dev BACKUP_PATH=/tmp/timenest DATA_DIR=/tmp/timenest-data
mkdir -p /tmp/timenest /tmp/timenest-data
uvicorn app.main:app --reload --port 8080
```

## Style

- Python: `ruff` with default rules, `mypy --strict` where practical. 4 spaces. Type hints on all public functions.
- Shell: `shellcheck` clean. `set -euo pipefail` at the top of every script.
- YAML / config templates: 4 spaces, keys in logical groups, comments explain *why*.
- No new runtime dependencies without a PR-description-level justification.

## Testing

- `ci.yml` runs `ruff`, `mypy`, `shellcheck`, and a `testparm -s` smoke test of the rendered `smb.conf`.
- `docker.yml` builds all three images for `amd64`, `arm64`, and `arm/v7`.
- Please confirm a real backup still works end to end on at least one Mac before opening a PR that touches `smb.conf.template`, the Avahi service, or `vfs_fruit` parameters.

## Commits and PRs

- Conventional Commits (`feat:`, `fix:`, `docs:`, ...).
- One logical change per PR. Split refactors from behavior changes.
- Include a screenshot for any UI change.

## Scope

Things that are in scope:
- Reliability of the core backup path.
- Better observability (metrics, logs, health checks).
- Performance tuning of Samba / vfs_fruit for specific hardware.
- UX polish on the admin UI that does not introduce a JS build step.

Things that are usually out of scope:
- Cloud syncing (S3, B2, etc.) beyond what is already on the roadmap.
- Non-Mac clients (Windows File History, Linux borg, etc.).
- Rewriting the web UI in a SPA framework.
- Packaging the whole thing as a snap / flatpak / homebrew formula before v1.0.

## License

By contributing you agree that your work is licensed under the MIT license, the same license as the rest of the project.
