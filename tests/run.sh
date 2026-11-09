#!/usr/bin/env bash
# Test clean-msg.sh and install-hook.sh in throwaway repos. Never touches real repos.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLEAN="$ROOT/scripts/clean-msg.sh"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
pass=0; fail=0
ok(){ echo "  ✓ $1"; pass=$((pass+1)); }
ko(){ echo "  ✗ $1"; fail=$((fail+1)); }

expect(){ # name, want(0|1), message, [expected-output]
  printf '%b' "$3" > "$W/m"
  bash "$CLEAN" "$W/m" 2>/dev/null; got=$?
  [[ $got -eq $2 ]] || { ko "$1 (exit $got, want $2)"; return; }
  if [[ $# -ge 4 ]]; then [[ "$(cat "$W/m")" == "$(printf '%b' "$4")" ]] || { ko "$1 (output: $(cat "$W/m" | tr '\n' '|'))"; return; }; fi
  ok "$1"
}

echo "clean-msg.sh"
expect "strips Claude trailer" 0 "feat(auth): add refresh token\n\nWhy.\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\n\n" "feat(auth): add refresh token\n\nWhy."
expect "strips Generated with Claude Code" 0 "fix: handle null\n\n🤖 Generated with [Claude Code](https://claude.com/claude-code)\n" "fix: handle null"
expect "strips Copilot trailer" 0 "docs: fix typo\n\nCo-authored-by: Copilot <copilot@github.com>" "docs: fix typo"
expect "keeps human co-author" 0 "fix: x\n\nCo-Authored-By: Ana <ana@example.com>" "fix: x\n\nCo-Authored-By: Ana <ana@example.com>"
expect "breaking change ok" 0 "feat(api)!: change response format\n\nBREAKING CHANGE: new shape"
expect "merge message ok" 0 "Merge branch 'dev'"
expect "revert message ok" 0 "Revert \"feat: add x\""
expect "rejects missing type" 1 "Added login."
expect "rejects trailing period" 1 "feat: add login."
expect "rejects unknown type" 1 "feature: add login"
expect "rejects uppercase scope" 1 "feat(UI): add button"
expect "rejects header > 72" 1 "feat: $(printf 'a%.0s' {1..80})"
expect "rejects missing blank line" 1 "feat: add x\nbody"
printf 'whatever.\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' > "$W/m"
bash "$CLEAN" "$W/m" --no-validate && [[ "$(cat "$W/m")" == "whatever." ]] && ok "--no-validate strips only" || ko "--no-validate strips only"

echo "install-hook.sh"
R="$W/repo"; mkdir "$R"; cd "$R"; git init -q; git config user.name t; git config user.email t@example.com
printf '#!/bin/sh\necho local-ran > "$(dirname "$0")/../local.flag"\n' > .git/hooks/commit-msg; chmod +x .git/hooks/commit-msg
bash "$ROOT/scripts/install-hook.sh" >/dev/null
echo a > f; git add f
git commit -q -m "feat: add f" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
[[ "$(git log -1 --format=%B | sed '/^$/d')" == "feat: add f" ]] && ok "hook strips trailer" || ko "hook strips trailer"
[[ -f .git/local.flag ]] && ok "previous hook still runs" || ko "previous hook still runs"
git commit -q --allow-empty -m "bad message" 2>/dev/null && ko "hook blocks bad header" || ok "hook blocks bad header"
bash "$ROOT/scripts/install-hook.sh" >/dev/null; [[ ! -f .git/hooks/commit-msg.local.local ]] && ok "reinstall is idempotent" || ko "reinstall is idempotent"
bash "$ROOT/scripts/install-hook.sh" --strip-only >/dev/null
git commit -q --allow-empty -m "WIP stuff" -m "Co-Authored-By: Claude <noreply@anthropic.com>" && [[ "$(git log -1 --format=%B | sed '/^$/d')" == "WIP stuff" ]] && ok "--strip-only allows any style" || ko "--strip-only allows any style"
cp -R "$ROOT/scripts" "$W/skilltmp"; R2="$W/repo2"; mkdir "$R2"; cd "$R2"; git init -q; git config user.name t; git config user.email t@example.com
bash "$W/skilltmp/install-hook.sh" >/dev/null; rm -rf "$W/skilltmp"
git commit -q --allow-empty -m "chore: hook works standalone" && ok "hook works after skill is removed" || ko "hook works after skill is removed"

echo "detect-language.sh"
L="$ROOT/scripts/detect-language.sh"; P="$W/proj"; H="$W/home"; mkdir -p "$P/.claude" "$H/.claude"; cd "$P"
[[ "$(HOME=$H CLAUDE_CONFIG_DIR= bash "$L")" == "English" ]] && ok "defaults to English" || ko "defaults to English"
echo '{"language":"Español"}' > "$H/.claude/settings.json"
[[ "$(HOME=$H CLAUDE_CONFIG_DIR= bash "$L")" == "Español" ]] && ok "reads user setting" || ko "reads user setting"
echo '{"language":"français"}' > .claude/settings.json
[[ "$(HOME=$H CLAUDE_CONFIG_DIR= bash "$L")" == "français" ]] && ok "project beats user" || ko "project beats user"
echo '{"language":"Deutsch"}' > .claude/settings.local.json
[[ "$(HOME=$H CLAUDE_CONFIG_DIR= bash "$L")" == "Deutsch" ]] && ok "local beats project" || ko "local beats project"
rm .claude/*.json; mkdir "$W/cfg"; echo '{"language":"日本語"}' > "$W/cfg/settings.json"
[[ "$(HOME=$H CLAUDE_CONFIG_DIR=$W/cfg bash "$L")" == "日本語" ]] && ok "honors CLAUDE_CONFIG_DIR" || ko "honors CLAUDE_CONFIG_DIR"
printf 'feat(auth): agrega rotación del token\n\nPorque las sesiones caducaban.\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' > "$W/m"
bash "$CLEAN" "$W/m" && ! grep -qi claude "$W/m" && ok "non-English description validates" || ko "non-English description validates"

echo; echo "$pass passed, $fail failed"; [[ $fail -eq 0 ]]
