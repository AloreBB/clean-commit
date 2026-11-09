#!/usr/bin/env bash
# Print the language configured in Claude Code (`language` setting), or "English".
# Precedence: project settings.local.json > project settings.json > user settings.
# Read-only. Run from the repository root.
set -euo pipefail
user_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
for f in .claude/settings.local.json .claude/settings.json "$user_dir/settings.json"; do
  [[ -f "$f" ]] || continue
  if command -v jq >/dev/null 2>&1; then
    lang="$(jq -r '.language // empty' "$f" 2>/dev/null || true)"
  else
    lang="$(sed -nE 's/.*"language"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$f" | head -n1)"
  fi
  if [[ -n "$lang" ]]; then echo "$lang"; exit 0; fi
done
echo "English"
