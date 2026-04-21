# Twitter / X and Mastodon launch thread

Three drafts. Pick whichever one resonates on the day.

## Draft A - concise and factual

```
1/ I open-sourced TimeNest today.

It turns any Mac mini, Raspberry Pi, or Linux box into a Time Machine
target for every Mac on your LAN. No iCloud. No dangling USB.

https://github.com/momenbasel/timenest
```

```
2/ Stack:
- Samba 4.18 + vfs_fruit (per-user TM shares w/ quotas)
- Avahi (Bonjour advertises as TimeCapsule8,119)
- FastAPI + htmx admin UI at :8080
- All wrapped in one docker compose up

Multi-arch images for amd64, arm64, armv7.
```

```
3/ Benchmarks on a 100 GB first backup:

Mac mini M2 + NVMe - 18m 42s @ 89 MB/s
RPi 5 + NVMe       - 21m 05s @ 79 MB/s
RPi 4 + SATA SSD   - 27m 30s @ 61 MB/s

MIT licensed. No telemetry. Built because living out of a USB cable isn't a backup strategy.
```

## Draft B - hook-led

```
Apple killed the Time Capsule in 2018.
iCloud costs $119/yr and doesn't back up your disk.
Synology NAS is $300+ of overkill for one job.

So I built TimeNest: a Docker stack that turns any Pi or Mac mini into a
network Time Machine target. Open source, MIT:
https://github.com/momenbasel/timenest
```

## Draft C - technical one-liner (Mastodon / Bluesky)

```
TimeNest (new, MIT): Samba 4.18 + vfs_fruit + Avahi + a small FastAPI UI,
wrapped in a 3-container docker compose, so any Pi / Mac mini / Linux box
becomes a Time Capsule for every Mac on the LAN. Bonjour discovery works,
per-user quotas work, SMART shows in the dashboard, Prometheus endpoint
included. github.com/momenbasel/timenest
```

## Hashtags

Use sparingly:
```
#selfhosted #homelab #opensource #timemachine #macos #raspberrypi #docker
```

## Image

Attach `docs/social-preview.png`.
