#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/set-status.sh critical|warning|maintenance|clear
# Run from the repo root. Commits and pushes status.json to main.

SEVERITY="${1:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATUS_FILE="$REPO_ROOT/status.json"
TEMPLATES_DIR="$REPO_ROOT/templates"

if [[ -z "$SEVERITY" ]]; then
    echo "Usage: $0 critical|warning|maintenance|clear" >&2
    exit 1
fi

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
git add status.json
git commit -m "status: $SEVERITY"
git push origin main

echo "Published $SEVERITY status. GitHub Pages will update in ~1-3 minutes."
