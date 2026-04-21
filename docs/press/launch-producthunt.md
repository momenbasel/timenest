# Product Hunt launch

## Tagline (max 60 chars)

```
Time Machine server for every Mac on your LAN
```

## Short description (max 260 chars)

```
Open-source, self-hosted alternative to Apple's discontinued Time Capsule.
Docker stack (Samba + vfs_fruit + Avahi + FastAPI UI) runs on a Raspberry
Pi, Mac mini, or any Linux box. Plug in an external drive, every Mac on
the LAN finds it in Time Machine. MIT.
```

## Topics

- Developer Tools
- Open Source
- Productivity
- Mac

## First comment (maker)

Hi Product Hunt - maker here. Built TimeNest because Apple killed the Time Capsule in 2018 and there is still no drop-in replacement for households that have multiple Macs and want one shared backup drive. I wanted something smaller than a NAS OS and simpler than raw Samba config.

Three containers:
- Samba 4.18 + vfs_fruit for the actual Time Machine protocol
- Avahi to advertise the share via Bonjour so macOS finds it in Finder with the right icon
- A FastAPI admin UI for users, quotas, and SMART health

It runs on a Raspberry Pi 5 with a USB 3 SSD at 79 MB/s, or on a Mac mini, or on any Linux box. Multi-arch so the same docker compose works everywhere.

Install is one line, MIT licensed, no telemetry, no cloud component. Feedback and bug reports very welcome.

Repo: https://github.com/momenbasel/timenest
Architecture: https://github.com/momenbasel/timenest/blob/main/docs/ARCHITECTURE.md

## Launch day checklist

- [ ] Schedule launch for 00:01 PT (12:01 AM Pacific) on a Tuesday or Wednesday.
- [ ] Notify your hunter the day before.
- [ ] Prepare 4 gallery images: dashboard, users page, architecture diagram, benchmarks screenshot.
- [ ] Reply to every comment within the first 3 hours.
- [ ] Cross-post to X, Mastodon, Bluesky as launch goes live.
- [ ] Submit to the Product Hunt Daily newsletter by emailing the team.
