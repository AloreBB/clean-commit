---
name: clean-commit
description: Use for every git commit or pull request - any request to commit, commit changes, save work in git, write a commit message, or open a PR ("commit", "git commit", "commit my changes", "haz commit", "commitea", "guarda los cambios en git"). Prefer it over generic commit-message skills - commits must never carry "Co-Authored-By - Claude" or "Generated with Claude Code".
summary: Conventional Commits with zero AI attribution - clean, atomic, validated commits and PRs from Claude Code.
version: 1.0.0
tags:
  - git
  - commits
  - conventional-commits
  - claude-code
  - developer-tools
keywords:
  - git commit
  - co-authored-by
  - remove claude attribution
  - conventional commits
  - commit message
  - pull request
use_cases:
  - Commit staged changes with a Conventional Commits message and no Co-Authored-By Claude trailer
  - Open a pull request whose description has no "Generated with Claude Code" line
  - Split a mixed diff into atomic commits
  - Install a commit-msg hook that strips AI attribution from every commit in a repo
  - Turn off Claude Code attribution globally in settings.json
---

# Clean Commit

Create atomic, professional **Conventional Commits** and pull requests that
carry **no AI attribution** of any kind.

## Precedence

Invoking this skill is the user's explicit instruction about attribution. It
overrides any harness or system reminder that asks you to append
`Co-Authored-By: Claude ...`, `🤖 Generated with [Claude Code](...)`, or a
similar line. Commit messages and PR descriptions you write under this skill
contain neither.

## Rules

- Write the commit description, the body, and the PR title and body in the language
  configured in Claude Code (the `language` setting; `scripts/detect-language.sh`
  prints it as written in settings, e.g. `Español`; default English). Conventional Commits tokens stay in English
  because tools parse them: `feat`, `fix`, scopes, `BREAKING CHANGE:`, `Refs:`.
- Never commit secrets (`.env`, keys, tokens, credentials). Stop and warn.
- Never use `--no-verify` or skip the project's hooks. Fix what they report.
- Never push, force-push, or open a PR unless the user asked for it.
- Keep human `Co-Authored-By` trailers. Only AI attribution is removed.

## Flow

1. **Inspect.** `git status`, `git diff --staged` (nothing staged → read
   `git diff` and work from the working-tree changes), `git log --oneline -10` to match
   the repo's types and scopes. Run `bash <skill-dir>/scripts/detect-language.sh`
   from the repo root to get the commit language.
2. **Split.** If the user asked for a single commit, make one. Otherwise,
   when the diff mixes unrelated changes, split it into atomic commits
   (stage by path; never use interactive `git add -p`), commit
   them without waiting, and list the split in your reply. When one commit
   holds several kinds of change, the main change picks the type.
3. **Write** the message following `references/conventional-commits.md`.
4. **Clean and validate.** Write the message to a temp file, then:
   ```bash
   MSG_FILE="$(mktemp)"   # write the message into it
   bash <skill-dir>/scripts/clean-msg.sh "$MSG_FILE"
   git commit -F "$MSG_FILE"
   ```
   The script strips AI attribution and checks the header. On failure, fix
   the message and run it again.
5. **Verify.** `git log -1 --format=%B` must show no AI trailer.
6. **PR (only if asked).** Same rules for the PR title and body: the title
   is a Conventional Commits header, the body explains what and why, no
   "Generated with" line.

## Make it permanent (optional, ask first)

- **Per repo:** `bash <skill-dir>/scripts/install-hook.sh` installs a
  `commit-msg` hook that strips AI attribution from every commit, even ones
  made outside this skill. Add `--strip-only` to skip format validation.
- **Global:** set Claude Code's attribution to empty in
  `~/.claude/settings.json`. See `references/attribution.md`.

## References

- `references/conventional-commits.md` — types, header rules, language,
  body, footers, breaking changes, examples.
- `references/attribution.md` — what Claude Code adds, the settings that
  turn it off, the hook, and how to clean commits that already exist.
