# Awesome list submission targets

Shipped first, then followups ordered by audience size and review cadence.

## Shipped on launch day (2026-04-22)

| List                                                                      | Category             | PR                                                                          |
| ------------------------------------------------------------------------- | -------------------- | --------------------------------------------------------------------------- |
| [awesome-sysadmin](https://github.com/awesome-foss/awesome-sysadmin)      | Backups              | [awesome-foss/awesome-sysadmin#765](https://github.com/awesome-foss/awesome-sysadmin/pull/765) |
| [awesome-raspberry-pi](https://github.com/thibmaek/awesome-raspberry-pi) | Projects             | [thibmaek/awesome-raspberry-pi#306](https://github.com/thibmaek/awesome-raspberry-pi/pull/306) |
| [awesome-macOS](https://github.com/iCHAIT/awesome-macOS)                 | Applications/Backup  | [iCHAIT/awesome-macOS#790](https://github.com/iCHAIT/awesome-macOS/pull/790) |

**awesome-selfhosted is covered transitively.** Its Backup tag explicitly
redirects to `awesome-foss/awesome-sysadmin#backups` in
`tags/backup.yml`, so a landed PR on awesome-sysadmin propagates to
awesome-selfhosted's generated markdown automatically.

## Queued for follow-up (manual review cycles)

| List                                                                          | Reason it's delayed                                           |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------- |
| [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) | Structured YAML submissions + CI. Needs `software/*.yml` file.|
| [awesome-homelab](https://github.com/topics/homelab)                           | No single canonical list, many forks. Pick top-starred.       |
| [awesome-nas](https://github.com/awesome-foss/awesome-nas)                     | Stricter scope (NAS platforms), TimeNest is complementary.    |
| [awesome-open-source-backup](https://github.com/restic/awesome-backup)         | Maintainer response time is slow, queue last.                 |
| [awesome-foss/awesome-docker-compose](https://github.com/Haxxnet/Compose-Examples) | Compose recipe collection; submit a minimal example fork. |

## Submission template (reuse per list)

```
- [TimeNest](https://github.com/momenbasel/timenest) - Self-hosted network
  Time Machine server for every Mac on your LAN. Docker stack (Samba +
  vfs_fruit, Avahi, FastAPI admin UI) that runs on Mac mini, Raspberry Pi,
  or any Linux home server. Multi-arch (`amd64`, `arm64`, `armv7`). `MIT`
```

Alternate shorter version for lists with a strict 100-character entry cap:

```
- [TimeNest](https://github.com/momenbasel/timenest) - Self-hosted Time
  Machine server. Runs on Pi, Mac mini, or any Linux box. `MIT`
```
