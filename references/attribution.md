# AI attribution: what gets added and how to remove it

## What Claude Code adds by default

- Commits: a trailer `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.
- Pull requests: a line `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

`scripts/clean-msg.sh` removes these, plus equivalent lines from other AI
tools (Copilot, ChatGPT/OpenAI, Cursor, Codex, Gemini). Human co-authors
stay.

## Turn it off globally (ask before editing settings)

In `~/.claude/settings.json`, merge this key without touching the rest of
the file:

```json
{ "attribution": { "commit": "", "pr": "" } }
```

Older Claude Code versions use `"includeCoAuthoredBy": false` instead.
Back up the file first, and keep the JSON valid (`jq . settings.json`).

## Per-repo hook

`scripts/install-hook.sh` copies `clean-msg.sh` into the repo's hooks
directory and installs a `commit-msg` hook that runs it. The hook works
without this skill installed. An existing `commit-msg` hook is moved to
`commit-msg.local` and still runs. `--strip-only` cleans attribution
without validating the Conventional Commits format (use it in repos with
another message style).

Remove it: delete `.git/hooks/commit-msg` and `.git/hooks/clean-msg.sh`,
then rename `commit-msg.local` back if it exists.

## Commits that already carry attribution

Only with the user's approval, and only on commits not yet pushed:

- Last commit: `git commit --amend` with the cleaned message.
- Several local commits: rewrite with
  `git filter-branch --msg-filter` or `git rebase` with `reword`.

Rewriting pushed history needs a force-push and coordination with
everyone on the branch. Explain that and let the user decide.
