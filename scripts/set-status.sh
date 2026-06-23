#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/set-status.sh <dev|stage|prod> <critical|warning|maintenance|clear>
# Run from the repo root. Commits and pushes the env-specific status file to main.

ENV="${1:-}"
SEVERITY="${2:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/templates"

if [[ -z "$ENV" || -z "$SEVERITY" ]]; then
    echo "Usage: $0 <dev|stage|prod> <critical|warning|maintenance|clear>" >&2
    exit 1
fi

case "$ENV" in
    dev) STATUS_FILE="$REPO_ROOT/status-dev.json" ;;
    stage) STATUS_FILE="$REPO_ROOT/status-stage.json" ;;
    prod) STATUS_FILE="$REPO_ROOT/status-prod.json" ;;
    *)
        echo "Unknown environment: $ENV" >&2
        echo "Use: dev, stage, or prod" >&2
        exit 1
        ;;
esac

case "$SEVERITY" in
    clear)
        cp "$TEMPLATES_DIR/inactive.json" "$STATUS_FILE"
        ;;
    critical | warning | maintenance)
        cp "$TEMPLATES_DIR/$SEVERITY.json" "$STATUS_FILE"
        ;;
    *)
        echo "Unknown severity: $SEVERITY" >&2
        echo "Use: critical, warning, maintenance, or clear" >&2
        exit 1
        ;;
esac

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
if command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq --arg ts "$TIMESTAMP" '.updatedAt = $ts' "$STATUS_FILE" > "$tmp"
    mv "$tmp" "$STATUS_FILE"
else
    echo "Warning: jq not found; updatedAt not set" >&2
fi

cd "$REPO_ROOT"
git add "$STATUS_FILE"
git commit -m "status-$ENV: $SEVERITY"
git push origin main

echo "Published $SEVERITY status for $ENV. GitHub Pages will update in ~1-3 minutes."
