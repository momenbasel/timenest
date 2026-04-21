# TimeNest launch day checklist

A one-page run sheet. Keep this open in a second tab on launch day.

## T-7 days

- [ ] Finalize the README, social preview image, benchmarks table.
- [ ] Land all workflows green on `main` (CI + docker multi-arch build).
- [ ] Push first tagged release `v0.1.0` so `ghcr.io` tags exist.
- [ ] Write a short "what's next" roadmap into `README.md`.
- [ ] Upload the PNG under Repo Settings -> Social preview.

## T-1 day

- [ ] Pre-fill all press-kit drafts with your name, GitHub URL, screenshots.
- [ ] Queue the Twitter / Mastodon / Bluesky threads.
- [ ] Line up a Product Hunt hunter if you are going PH route.
- [ ] Warm up a friend or two to upvote Reddit posts in the first hour.

## Launch day - 08:00 local

- [ ] Submit Show HN.
- [ ] Post r/selfhosted thread.
- [ ] Send Twitter / Mastodon / Bluesky thread.
- [ ] Publish the blog post and cross-post to dev.to / Medium with canonical URL.

## Launch day - 11:00 local (after HN settles)

- [ ] Post r/homelab thread.
- [ ] Submit to Lobsters.
- [ ] Email the awesome-list maintainers whose PRs are still open, link to traction.

## Launch day - 14:00 local

- [ ] Post r/raspberry_pi thread (peak EU evening, US afternoon).
- [ ] Submit to Hacker News *only if* Show HN died below the fold early. Otherwise wait.

## Launch day - 18:00 local

- [ ] Reply to every comment left on any channel.
- [ ] Capture metrics: stars, clones, container pulls, referral sources.
- [ ] Write a short "launch day recap" draft for T+7.

## T+2 days

- [ ] Post r/macapps and r/docker threads.
- [ ] Submit to newsletter curators: TLDR, Console, Changelog News, Self-hosted Weekly.

## T+7 days

- [ ] Publish the launch recap post with metrics.
- [ ] Cut `v0.2.0` with whatever fixes came out of the first week of feedback.
- [ ] Thank everyone who contributed a PR or issue, by hand.

## Metrics to watch

| Channel       | Tool                                   | Target day-1 | Target week-1 |
| ------------- | -------------------------------------- | ------------ | ------------- |
| GitHub stars  | Repo page                              | 200          | 1500          |
| Clones        | Repo insights                          | 500          | 5000          |
| ghcr pulls    | `gh api /users/USER/packages/...`      | 100          | 1500          |
| HN rank       | https://news.ycombinator.com/show       | top 30       | front page    |
| Reddit shares | reddit.com/r/selfhosted                | 300 upvotes  | 1500 upvotes  |
| Docs traffic  | GitHub Traffic tab                     | 2000 views   | 15000 views   |
