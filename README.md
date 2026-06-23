# castle-status

Static maintenance / downtime banner config for [Castle web](https://github.com/castle-pay/castle-web).

The app polls an environment-specific JSON file from GitHub Pages — **independent of our API** — so users still see outage messaging when backend services are down.

- **Pages URL:** https://castle-pay.github.io/castle-status/

## Config files (one per environment)

| File | Used by |
| --- | --- |
| [`status-prod.json`](https://castle-pay.github.io/castle-status/status-prod.json) | Production (`app.getcastle.com`) |
| [`status-staging.json`](https://castle-pay.github.io/castle-status/status-staging.json) | Staging (`app-staging.getcastle.com`) |
| [`status-dev.json`](https://castle-pay.github.io/castle-status/status-dev.json) | Local dev (`yarn dev`) |

Each environment reads only its own file, so you can test banners on dev/staging without affecting production.

## Schema

```json
{
    "active": true,
    "severity": "critical",
    "title": "Castle is temporarily unavailable",
    "message": "Our team is working to restore service...",
    "showSupport": true,
    "updatedAt": "2026-06-23T20:00:00Z"
}
```

| Field | Type | Description |
| --- | --- | --- |
| `active` | boolean | When `false`, the banner is hidden |
| `severity` | `"critical"` \| `"warning"` \| `"maintenance"` | Controls banner color and icon |
| `title` | string | Bold headline |
| `message` | string | Supporting text |
| `showSupport` | boolean (optional) | Show "Need urgent help? support@getcastle.com" |
| `updatedAt` | string (optional) | ISO 8601 timestamp of last change |

## Activate the banner

### Option 1: GitHub Actions (recommended)

1. Go to **Actions** → **Set maintenance status** → **Run workflow**
2. Choose **environment** (`dev`, `staging`, or `prod`) and **severity** (`critical`, `warning`, `maintenance`, or `clear`)
3. Wait ~1–3 minutes for GitHub Pages to deploy; the app polls every 60s

Or from the CLI:

```bash
gh workflow run set-status.yml -f environment=dev -f severity=critical -R castle-pay/castle-status
gh workflow run set-status.yml -f environment=prod -f severity=clear -R castle-pay/castle-status
```

### Option 2: Shell script

```bash
./scripts/set-status.sh dev critical
./scripts/set-status.sh staging warning
./scripts/set-status.sh prod maintenance
./scripts/set-status.sh dev clear
```

Requires `jq`, git push access to `main`, and run from a local clone.

### Option 3: Manual edit

1. Edit the appropriate `status-{env}.json` (or copy from `templates/`)
2. Set `updatedAt` to the current UTC time (optional)
3. Commit and push to `main`

## Templates

| File | Use case |
| --- | --- |
| `templates/critical.json` | Full outage |
| `templates/warning.json` | Partial degradation |
| `templates/maintenance.json` | Planned maintenance |
| `templates/inactive.json` | Banner off (`active: false`) |

## Propagation

After pushing to `main`:

1. GitHub Pages deploy: ~30–90 seconds
2. App poll interval: up to 60 seconds
3. **Worst case end-to-end: ~2–3 minutes**

The frontend cache-busts fetches with `?t=timestamp` to avoid GitHub Pages CDN staleness.

## index.html

**Not required for the app** — `castle-web` only fetches the env-specific JSON files. `index.html` is included so humans visiting the Pages root URL get a short explanation instead of a 404.

## robots.txt

`robots.txt` disallows all crawlers so the GitHub Pages site is not indexed by search engines.
