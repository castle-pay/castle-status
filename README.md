# castle-status

Static maintenance / downtime banner config for [Castle web](https://github.com/castle-pay/castle-web).

The app polls `status.json` from GitHub Pages — **independent of our API** — so users still see outage messaging when backend services are down.

- **Pages URL:** https://castle-pay.github.io/castle-status/
- **Config file:** https://castle-pay.github.io/castle-status/status.json

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
2. Choose severity: `critical`, `warning`, `maintenance`, or `clear`
3. Wait ~1–3 minutes for GitHub Pages to deploy; the app polls every 60s

Or from the CLI:

```bash
gh workflow run set-status.yml -f severity=critical -R castle-pay/castle-status
gh workflow run set-status.yml -f severity=clear -R castle-pay/castle-status
```

### Option 2: Shell script

```bash
./scripts/set-status.sh critical
./scripts/set-status.sh warning
./scripts/set-status.sh maintenance
./scripts/set-status.sh clear
```

Requires `jq`, git push access to `main`, and run from a local clone.

### Option 3: Manual edit

1. Copy a file from `templates/` to `status.json`
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

## Do we need index.html?

**No** — the web app only fetches `status.json`. `index.html` is included so humans visiting the Pages root URL get a short explanation instead of a 404.
