#!/usr/bin/env bash
# Install a commit-msg hook in the current repo that strips AI attribution.
# Usage: install-hook.sh [--strip-only]
set -euo pipefail

mode=""
[[ "${1:-}" == "--strip-only" ]] && mode="--no-validate"

git rev-parse --git-dir >/dev/null 2>&1 || { echo "✗ not inside a git repository" >&2; exit 1; }
hooks_dir="$(git rev-parse --git-path hooks)"
mkdir -p "$hooks_dir"
hook="$hooks_dir/commit-msg"
marker="# clean-commit hook"

cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/clean-msg.sh" "$hooks_dir/clean-msg.sh"

if [[ -f "$hook" ]] && ! grep -q "$marker" "$hook"; then
  mv "$hook" "$hook.local"
  echo "• existing hook moved to $hook.local (it still runs)"
fi

cat > "$hook" <<HOOK
#!/usr/bin/env bash
$marker
set -e
dir="\$(dirname "\$0")"
bash "\$dir/clean-msg.sh" "\$1" $mode
if [[ -x "\$dir/commit-msg.local" ]]; then "\$dir/commit-msg.local" "\$1"; fi
HOOK
chmod +x "$hook"
echo "✓ commit-msg hook installed in $hook${mode:+ (strip-only)}"
