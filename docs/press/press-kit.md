# TimeNest press kit

Everything a writer, podcaster, or reviewer needs. Use whatever fits your format; nothing here is under embargo.

## One-liner

**Turn any Mac mini, Raspberry Pi, or Linux home server into a Time Machine target for every Mac on your LAN.**

## One paragraph

TimeNest is an open-source self-hosted alternative to Apple's discontinued Time Capsule. It packages Samba 4.18 with `vfs_fruit`, Avahi for Bonjour discovery, and a dark-mode FastAPI admin UI into a single `docker compose` stack. Point `BACKUP_PATH` at an external drive and every Mac on the LAN sees a Time Machine target with a native Time Capsule icon in Finder - no IP typing, no SMB URLs, no iCloud upsell. Works on `linux/amd64`, `linux/arm64`, and `linux/arm/v7` so the same stack runs on a Raspberry Pi 5, a Mac mini, or a decommissioned NUC.

## Facts and figures

| Fact                        | Value                                                          |
| --------------------------- | -------------------------------------------------------------- |
| License                     | MIT                                                            |
| Language                    | Python 3.12 (web UI), shell (ops), Samba / Avahi               |
| First public commit         | 2026-04-22                                                     |
| Repo                        | https://github.com/momenbasel/timenest                         |
| Container registry          | ghcr.io/momenbasel/timenest-{samba,avahi,web}                  |
| Architectures               | linux/amd64, linux/arm64, linux/arm/v7                         |
| Minimum hardware            | 2 cores, 1 GB RAM, 100 Mbit LAN                                |
| Tested macOS versions       | Ventura, Sonoma, Sequoia                                       |
| Protocols                   | SMB3, Bonjour/mDNS                                             |
| Deps at runtime             | Docker + docker compose. Nothing else.                         |

## Headline comparisons

- Replaces the Apple Time Capsule (discontinued 2018) without buying used hardware.
- Cheaper than a Synology DS224+ for households that only need Time Machine.
- Simpler than OpenMediaVault / TrueNAS for users who just want macOS backups.
- Unlike iCloud Backup, TimeNest backs up the entire disk, not only iCloud Drive + Photos.

## Suggested angles

- *Resurrecting the Time Capsule on a Raspberry Pi 5* - hardware-review framing.
- *How to actually back up your Mac in 2026 without paying Apple $119/year* - consumer angle.
- *A minimal Samba + Avahi + FastAPI stack, explained* - developer deep dive.
- *From discontinued Apple hardware to community-run backup* - sustainability / right-to-repair angle.

## Screenshots

See `docs/screenshots/`. To regenerate the social preview image, run:

```bash
python3 docs/press/social-preview.py
```

## Contact

Project lead: Moamen Basel - ceo@greycorelabs.com - github.com/momenbasel

## Boilerplate

> TimeNest is an MIT-licensed self-hosted network Time Machine server. It runs on Mac mini, Raspberry Pi, or any Linux home server and replaces Apple's discontinued Time Capsule. Project home: https://github.com/momenbasel/timenest
