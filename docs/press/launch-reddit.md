# Reddit launch plan

Reddit is the highest-leverage channel for this project because three of its largest communities have exactly the audience. Hit them in this order, spaced 12 to 24 hours apart to avoid the anti-spam filter on cross-posting.

## 1. r/selfhosted

**Title**

```
TimeNest - Self-hosted Time Machine server for every Mac on your LAN (Docker, multi-arch, MIT)
```

**Body**

Hey r/selfhosted,

Sharing a project I just open-sourced. TimeNest packages Samba 4.18 + vfs_fruit, Avahi for Bonjour, and a FastAPI admin UI into one `docker compose` stack. Point it at an external drive, create a user per Mac in the web UI, and every Mac on the LAN picks the share up in Finder with a native Time Capsule icon. No iCloud. No dangling USB.

- Runs on Mac mini, RPi 4/5, and x86 Linux (multi-arch images).
- Per-user SMB shares with Time Machine quotas.
- Prometheus `/metrics` endpoint, SMART health in the dashboard.
- MIT licensed, no telemetry.

Repo: https://github.com/momenbasel/timenest
Architecture deep dive: https://github.com/momenbasel/timenest/blob/main/docs/ARCHITECTURE.md

Would love feedback on the Samba tuning in particular.

## 2. r/homelab

**Title**

```
Replacing the Apple Time Capsule with a Raspberry Pi 5 and Docker - TimeNest, open source
```

**Body**

Built TimeNest to resurrect Time Capsule functionality on a homelab. Three-container stack, works on a $80 Pi 5 with a USB3 SSD and hits ~79 MB/s on a 100 GB first backup. Multi-arch so it also runs on my Mac mini server.

Repo + full benchmarks: https://github.com/momenbasel/timenest

Happy to answer setup / tuning questions.

## 3. r/raspberry_pi

**Title**

```
I turned a Pi 5 into a Time Capsule replacement for every Mac in the house - full writeup
```

**Body**

Quick writeup. Hardware: Pi 5 8GB + USB 3 NVMe enclosure + gigabit. Software: TimeNest, a Docker stack I published today that wraps Samba + vfs_fruit + Avahi + a small admin UI. The Pi shows up in Finder on every Mac as a Time Capsule and handles concurrent backups.

100 GB first backup completes in about 21 minutes at 79 MB/s sustained.

Repo: https://github.com/momenbasel/timenest

## 4. r/macapps

**Title**

```
Free, open-source Time Capsule replacement that runs on a Pi, Mac mini, or any Linux box
```

**Body**

If you miss the Time Capsule and do not want to pay $119/yr for iCloud that still does not back up your whole disk, TimeNest might be for you. Drop it on any Linux-capable box, point it at an external drive, and every Mac finds it in Time Machine settings automatically.

https://github.com/momenbasel/timenest

## 5. r/apple (careful - low tolerance for self-promo)

Only post if the project has already picked up traction elsewhere. Frame as news, not launch.

## 6. r/opensource and r/docker

Shorter versions of the r/selfhosted post. Adjust focus toward packaging (r/docker) or licensing and governance (r/opensource).

## Submission hygiene

- Never cross-post the same body text on the same day; Reddit shadow-filters duplicate submissions.
- Post between 09:00 and 11:00 local time for the subreddit's main audience (US-East for most tech subs).
- Reply to every comment inside the first 4 hours. Lurk for longer.
- If a mod DMs you about rule 4 (self-promo), accept the takedown and re-post with a clearer value-first title.
