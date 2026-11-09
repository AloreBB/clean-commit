#!/usr/bin/env bash
# Strip AI attribution from a commit message file and validate Conventional Commits.
# Usage: clean-msg.sh <message-file> [--no-validate]
set -euo pipefail

file="${1:?usage: clean-msg.sh <message-file> [--no-validate]}"
validate=1
[[ "${2:-}" == "--no-validate" ]] && validate=0

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# 1) Drop AI attribution lines (human co-authors are kept).
grep -viE \
  -e '^[[:space:]]*co-authored-by:.*(claude|anthropic|copilot|chatgpt|openai|cursor|codex|gemini)' \
  -e 'generated (with|by) .*(claude|anthropic|copilot|chatgpt|cursor|codex|gemini)' \
  -e 'claude\.(com|ai)/(claude-code|code)' \
  "$file" > "$tmp" || true

# 2) Trim trailing whitespace and trailing blank lines.
sed -e 's/[[:space:]]*$//' "$tmp" \
  | awk '{ l[NR]=$0 } END { n=NR; while (n>0 && l[n]=="") n--; for (i=1;i<=n;i++) print l[i] }' > "$file"

[[ $validate -eq 0 ]] && exit 0

# 3) Validate the header. Git-generated messages are accepted as is.
body="$(grep -v '^#' "$file" || true)"
header="$(printf '%s\n' "$body" | head -n1)"
if [[ "$header" =~ ^(Merge|Revert\ \"|fixup!|squash!|amend!) ]]; then exit 0; fi

re='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: [^[:space:].](.*[^.])?$'
if [[ ! "$header" =~ $re ]]; then
  echo "✗ header is not a Conventional Commit: \"$header\"" >&2
  echo "  expected: <type>(<scope>)?!?: <description>   (no trailing period)" >&2
  exit 1
fi
if (( ${#header} > 72 )); then
  echo "✗ header is ${#header} characters (max 72): \"$header\"" >&2
  exit 1
fi
if [[ -n "$(printf '%s\n' "$body" | sed -n '2p')" ]]; then
  echo "✗ line 2 must be blank (separates header and body)" >&2
  exit 1
fi
