# SEO notes

GitHub is an SEO surface. TimeNest's README aims for these high-value search intents:

- "apple time capsule alternative"
- "self hosted time machine"
- "raspberry pi time machine server"
- "time machine docker"
- "mac mini time machine server"
- "samba time machine vfs_fruit"
- "free time capsule replacement"
- "network backup for multiple macs"

## What GitHub's crawler uses

| Surface                     | Source                                        |
| --------------------------- | --------------------------------------------- |
| `<title>`                   | `<org>/<repo>: <description>`                 |
| `<meta description>`        | Repo description (set via `gh repo edit`)     |
| `<meta og:image>`           | Social preview image, else first README image |
| H1 on repo page             | Repo name                                     |
| README H1                   | Used as page heading in search snippets       |
| Topics                      | Indexed as tag chips, surface in topic pages  |

## Reinforcement we control in this repo

- README H1 is the plain project name.
- The first paragraph mentions `Mac mini`, `Raspberry Pi`, `Time Capsule`, `Time Machine`, `home server`, `SMB` within the first 400 characters.
- Every section heading is a searchable phrase.
- `TimeNest` is never misspelled; `timenest` (lowercase) appears in URLs only.
- All three images have meaningful `alt` text.
- `docs/social-preview.png` is committed so GitHub can use it as og:image.
- Architecture diagram is Mermaid, not an image, so the query terms inside are still indexable as text.

## Channels that drive long-tail traffic

- awesome-list entries (github.com links from those repos, which are high PageRank).
- dev.to cross-post (auto-indexed, high DA).
- Reddit post (often the #1 Google result for long-tail "how do I back up my Mac to a Pi").
- Hacker News discussion (front page archives are crawled and surface in search for years).
- Product Hunt (indexed, directory-style).

## Monitoring

Check weekly:

```bash
gh api "/search/repositories?q=timenest+in:name+in:description" \
  --jq '.items[] | {full_name, stargazers_count}'
```

Google Search Console is not applicable because we do not control the github.com domain, but Google's `site:github.com/momenbasel/timenest` query works as a rough indexing check.
