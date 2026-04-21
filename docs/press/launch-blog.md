# Launch blog post

Draft for a personal blog, dev.to, Medium, or the Greycorelabs site. ~1,200 words. Cross-post as-is; canonical URL should point back to the personal blog for SEO.

---

# Resurrecting the Time Capsule: announcing TimeNest

Apple killed the Time Capsule in 2018. It was one of those Apple products that did one job, did it well, and disappeared without a successor. Five years on, the state of the art for backing up a Mac over the network is:

1. Pay $119 a year for iCloud, which does not back up your full disk.
2. Buy a $300+ NAS whose web UI you will spend more time configuring than using.
3. Plug an external SSD into every Mac, every day, and hope nobody forgets.
4. Follow a 900-line Reddit thread about `smb.conf` and `avahi-daemon.conf` and pray.

Option 4 is what I wanted, minus the Reddit thread. TimeNest is what came out of that.

## What TimeNest does

It turns any computer running Docker into a Time Machine target for every Mac on your network. Point it at an external drive, create a user per Mac in the web UI, and the share appears in Finder with a Time Capsule icon. You never type an IP address.

Under the hood it is a three-container stack:

- **Samba 4.18 with vfs_fruit.** The actual SMB server speaking Time Machine's dialect. Per-user shares with `fruit:time machine max size` quotas so one Mac cannot fill the drive. SMB signing is on by default and SMB1 is disabled.
- **Avahi.** The Bonjour daemon advertising the server as a `TimeCapsule8,119`. This is the piece that makes macOS show the share in the Time Machine picker without you ever typing `smb://`.
- **FastAPI + Jinja + htmx.** A small admin UI at `:8080` for creating users, watching live SMB sessions, reading SMART health off the drive, and exposing Prometheus metrics.

Multi-arch CI pushes images to `ghcr.io` for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`, so the same `docker compose` works on a Raspberry Pi 5, a Mac mini, a NUC, or an old laptop in a closet.

## Why this is a one-weekend project and not a startup

TimeNest doesn't need to exist as a SaaS. The hard part was always the Samba + Avahi + `vfs_fruit` configuration, and that configuration is static - once you get the `smb.conf` right, it stays right. The wrapper around it is fifty lines of shell and a tiny FastAPI app.

What the wrapper buys you is:

- A single `docker compose up -d` instead of ten pages of manual setup.
- Automatic Bonjour advertisement, so macOS picks it up natively.
- Per-user quotas and a web UI so adding a housemate or a new MacBook is a 30-second task.
- Prometheus metrics and SMART health, so you notice when a drive is dying before Time Machine fails silently for three weeks.
- One install path that works identically on a Pi, a Mac mini, and a NUC.

Nothing here is novel. Samba has spoken Time Machine since 2017. Avahi has advertised Bonjour records since forever. FastAPI is boring in the best possible way. TimeNest's contribution is the *packaging*: taking five well-understood Unix tools and producing one appliance that costs zero dollars and works out of the box.

## How to try it

```bash
# Linux / Raspberry Pi / WSL
curl -fsSL https://raw.githubusercontent.com/momenbasel/timenest/main/install.sh | bash
```

The installer handles Docker bootstrap, prompts for the drive path and admin password, writes `.env`, and brings up the stack. Five minutes on a Pi. Three on a NUC.

For Mac mini hosts, install Docker Desktop, enable host networking under Settings -> Resources -> Network, and run `docker compose up -d`. The rest is identical.

## Benchmarks

I tested a 100 GB first backup from a MacBook Pro M2 across three server configurations and two drive types. Time Machine's nemesis is small-file overhead, not raw throughput, so these numbers are more interesting than the peak SMB throughput you would see with `dd`.

- Mac mini M2 + USB 3.2 NVMe + gigabit: 18m 42s at 89 MB/s sustained.
- Raspberry Pi 5 + USB 3 NVMe + gigabit: 21m 05s at 79 MB/s sustained.
- Raspberry Pi 4 + USB 3 SATA SSD + gigabit: 27m 30s at 61 MB/s sustained.
- Intel NUC 10 + SATA HDD + gigabit: 34m 10s at 49 MB/s sustained.
- Raspberry Pi 4 + USB 2 HDD + gigabit: 1h 02m 15s at 27 MB/s sustained.

The Pi 5 result surprised me. A Pi with an NVMe SSD is now within 10% of a Mac mini's backup throughput for the same price of an iCloud subscription.

## What TimeNest is not

It is not a NAS. It is not a cloud backup. It is not a drop-in Synology replacement. It does one thing: be the Time Machine target for the Macs in your life.

It also does not support Windows File History, Linux `borg`, or anything else. If you want those, run your existing NAS OS and let TimeNest live in a corner doing the Mac-specific job.

## Open source and what is next

TimeNest is MIT. Source at https://github.com/momenbasel/timenest. The roadmap is short on purpose:

- SMTP / Telegram / webhook alerts on backup failure.
- Optional `mdadm` wizard for RAID1 across two drives.
- Encrypted off-site replication to S3 / Backblaze B2.
- Web-based sparsebundle browser with restore.

If any of that is interesting, open an issue or a PR. I am particularly interested in other people's `vfs_fruit` tuning notes and in reports from non-US network setups where mDNS behaves oddly.

Living out of a dangling USB cable is not a backup strategy. Put TimeNest on the Pi you have in a drawer and never think about Time Machine again.
