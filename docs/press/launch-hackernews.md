# Hacker News launch post

Submission type: **Show HN**.

## Title (80 char hard limit)

```
Show HN: TimeNest - network Time Machine for every Mac on your LAN
```

## URL

```
https://github.com/momenbasel/timenest
```

## Text (optional Show HN comment)

Hey HN,

Apple killed the Time Capsule in 2018 and removed AFP from macOS 11, which left a gap: there is no supported, zero-config way to point multiple Macs at a shared network drive for Time Machine. Third-party NASes (Synology, TrueNAS, OMV) cover it, but they are heavy for a household or small office whose only requirement is macOS backup.

TimeNest is a three-container Docker stack that fills that gap:

- `samba` - Samba 4.18 with `vfs_fruit`, per-user Time Machine shares with `fruit:time machine max size` quotas, SMB signing on by default.
- `avahi` - Bonjour advertisement as a `TimeCapsule8,119` so the share appears in Finder with the correct icon without typing an IP.
- `web` - FastAPI + Jinja + htmx admin UI at `:8080` for user management, quotas, SMART health, and `/metrics` for Prometheus.

Built for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`, so the same stack runs on a Raspberry Pi 5, a Mac mini (Intel or Apple Silicon), or any Linux box. Multi-arch images push to `ghcr.io` in CI.

Benchmarks on a 100 GB first backup:
- Mac mini M2 + USB3 NVMe: 18m 42s (89 MB/s)
- RPi 5 + USB3 NVMe: 21m 05s (79 MB/s)
- RPi 4 + USB3 SATA SSD: 27m 30s (61 MB/s)

One-liner install:

```
curl -fsSL https://raw.githubusercontent.com/momenbasel/timenest/main/install.sh | bash
```

MIT-licensed. No telemetry. Runs entirely offline. Would love feedback on the
Samba / `vfs_fruit` tuning in particular - the defaults in `smb.conf.template`
are what worked for me across three Macs and two Pis, but I know people have
pushed this further.

## Posting checklist

- [ ] Post between 08:00 and 10:00 ET on a weekday (peak traffic).
- [ ] Avoid Fridays and holidays.
- [ ] First comment should be a "Show HN" context reply, not a self-promo.
- [ ] Reply to every top-level comment within the first 2 hours - front page decay is brutal.
- [ ] If it dies below the fold on the first attempt, do not re-submit for at least 30 days. Wait for feature news.
