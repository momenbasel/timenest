# Awesome list submission targets

Shipped first, then followups ordered by audience size and review cadence.

## Shipped on launch day

| List                                                                 | Category TimeNest fits in           | PR submitted | Link |
| -------------------------------------------------------------------- | ----------------------------------- | ------------ | ---- |
| [awesome-sysadmin](https://github.com/awesome-foss/awesome-sysadmin) | Backups / Storage                   | -            |      |
| [awesome-raspberry-pi](https://github.com/thibmaek/awesome-raspberry-pi) | Projects                        | -            |      |
| [awesome-docker](https://github.com/veggiemonk/awesome-docker)       | Projects - Storage                  | -            |      |
| [awesome-macOS](https://github.com/iCHAIT/awesome-macOS)             | Utilities                           | -            |      |

(The "PR submitted" column is filled in at launch by the automation in
`scripts/submit-awesome-prs.sh`. That script forks each list, writes a
category entry, opens a PR, and appends the PR URL here.)

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
