# Listing copy (English, for the Agensi listing form)

Price: **Free**. Listing: https://agensi.io/skills/remove-claude-co-author-pro-commits-in-your-language

## Name (≤60 chars)

Remove Claude Co-Author: Pro Commits in Your Language

## Summary (≤300 chars)

Professional Conventional Commits from Claude Code with zero AI
attribution: no "Co-Authored-By: Claude", no "Generated with Claude
Code". Atomic, validated, written in your configured language, with an
optional hook that keeps every commit clean.

## Description (Markdown)

**Your history, your name.** Claude Code signs every commit with
`Co-Authored-By: Claude` and every PR with "Generated with Claude Code".
This skill makes commits that read like a senior engineer wrote them —
and carry no AI attribution.

- **Conventional Commits, done right** — `feat`, `fix`, `refactor`,
  scopes from your own history, imperative headers ≤72 chars, a body
  that explains *why*, `BREAKING CHANGE` footers.
- **Atomic by default** — mixed diffs get split into focused commits.
- **Your language** — messages follow the `language` you set in Claude
  Code; spec keywords stay in English so tooling keeps working.
- **Validated** — a bundled script strips AI trailers (Claude, Copilot,
  ChatGPT, Cursor, Codex, Gemini) and rejects malformed headers before
  the commit lands. Human co-authors are kept.
- **Permanent, if you want** — one command installs a `commit-msg` hook
  that cleans every commit in the repo, even ones made by hand or other
  tools. It chains your existing hook and works without the skill.
- **Safe** — never commits secrets, never skips your hooks with
  `--no-verify`, never pushes unless you ask.

## See it in action (700+ chars)

You finish a feature and type "commit this". Instead of one sprawling
commit signed by Claude, your agent reads the staged diff and the last
ten commits, notices you touched both the auth module and the README,
and proposes two commits. It checks your Claude Code settings, sees your
language is Spanish, and writes `feat(auth): agrega rotación del refresh
token` with a two-line body explaining why sessions were dropping, then
`docs(readme): documenta la instalación`. Before each commit the bundled
script removes the `Co-Authored-By: Claude` trailer the harness wanted
to add and validates the header. `git log` shows two clean, atomic
commits under your name only. Later you ask for a pull request: the
title is a Conventional Commits header, the body explains what changed
and why, and there is no "Generated with Claude Code" line. You like it
enough to make it permanent, so the agent installs a commit-msg hook in
the repo. From then on even commits you make from your IDE or another
assistant come out clean, and badly formed headers are rejected before
they reach history.

## Categories (up to 3, confirm against Agensi taxonomy)

1. Developer Tools
2. Git & Version Control
3. Claude Code

## Compatibility note

Built for Claude Code on macOS, Linux, or WSL with `bash` and `git`
(`jq` optional). The commit-message rules and hook work with any git
client; automatic language detection reads Claude Code settings.
