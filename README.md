# clean-commit

Agensi Skill: Conventional Commits with zero AI attribution for Claude
Code. Commercial name: **Clean Commits for Claude Code**.

The skill makes atomic Conventional Commits and pull requests without
`Co-Authored-By: Claude` or `Generated with Claude Code`. It writes the
message in the language configured in Claude Code (the `language` setting)
and can install a `commit-msg` hook that keeps every commit in a repo clean.

## Layout

- `SKILL.md` — short English router: precedence, rules, flow.
- `references/` — `conventional-commits.md`, `attribution.md`.
- `scripts/` — `clean-msg.sh` (strip + validate), `install-hook.sh`
  (per-repo hook), `detect-language.sh` (reads Claude Code `language`).
  Bash only, no network, no dependencies beyond git (jq optional).
- `tests/` — `run.sh`, script tests in throwaway repos. Excluded from the ZIP.
- `marketplace/` — shipping material, excluded from the Skill ZIP.

## Shipping ZIP

Zip only `SKILL.md`, `references/`, and `scripts/`:

```bash
zip -r clean-commit.zip SKILL.md references scripts
```

Never include `marketplace/` or `tests/`.

## Test

```bash
bash tests/run.sh
```

Runs every case in temp repos and a temp `HOME`; never touches real repos
or `~/.claude`.
