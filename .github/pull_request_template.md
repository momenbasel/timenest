<!--
Thanks for contributing.

Before submitting:
  1. Run `docker compose up --build` locally and confirm a Mac still sees
     the share in Finder.
  2. If you touched `smb.conf.template`, the Avahi service, or any
     `vfs_fruit` parameter, do a real 10 GB backup to prove Time Machine
     still completes successfully.
  3. Keep PRs small. Split refactors from behavior changes.
-->

## What

<!-- One or two sentences. What does this PR change? -->

## Why

<!-- Link to the issue or describe the motivation. -->

## How to verify

<!-- Commands the reviewer can run locally to verify the change. -->

## Screenshots

<!-- Required for any UI change. Drag-drop the image into this textarea. -->

## Checklist

- [ ] `docker compose up --build` still comes up clean.
- [ ] `ci.yml` passes locally (`ruff check web/`, `shellcheck scripts/*.sh`).
- [ ] I tested a real Time Machine backup end to end (only required for backup-path changes).
- [ ] Docs updated (README, ARCHITECTURE, or `.env.example`).
