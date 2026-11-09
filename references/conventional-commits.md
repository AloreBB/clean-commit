# Conventional Commits

```
<type>(<scope>)<!>: <description>

<body: why the change was made, wrapped at 72 columns>

<footers: Refs: #123 | Closes: #45 | BREAKING CHANGE: ...>
```

## Types

| type | Use for |
|------|---------|
| feat | A new feature |
| fix | A bug fix |
| docs | Documentation only |
| style | Formatting, no logic change |
| refactor | Neither a feature nor a fix |
| perf | Performance |
| test | Adding or fixing tests |
| build | Build system, dependencies |
| ci | CI configuration |
| chore | Maintenance that touches no src or tests |
| revert | Reverts a previous commit |

## Header rules

- Imperative mood, lowercase after the colon: `add`, not `added`/`adds`.
- At most 72 characters (aim for 50), no trailing period.
- `scope` is optional, lowercase, names an area: `api`, `ui`, `auth`, `db`.
- Follow the scopes the repo already uses in `git log`.
- Second line is blank. The body starts on line three.

## Language

Write the description, body, and PR text in the language configured in
Claude Code (`language` in settings.json; project `settings.local.json` >
project `settings.json` > user `settings.json`). `scripts/detect-language.sh`
prints it and falls back to English. Keep the machine-read tokens in
English: type, scope, `!`, `BREAKING CHANGE:`, `Refs:`, `Closes:`.

```
language: "Español"  →  feat(auth): agrega rotación del refresh token
language: unset      →  feat(auth): add refresh token rotation
```

## Body

Explain **why** and the impact, not a line-by-line replay of the diff. Use
bullets for several related changes. Skip the body for trivial commits.

## Breaking changes

Mark them twice: `!` after type/scope **and** a `BREAKING CHANGE:` footer
saying what users must migrate.

## Examples

```
feat(auth): add refresh token rotation

Sessions expired after 15 minutes and logged users out mid-task.
Rotate the refresh token on every use and revoke the old one.

Refs: #142
```

```
fix(api): return 404 for missing user profile
```

```
feat(api)!: wrap responses in a data envelope

BREAKING CHANGE: clients must read payloads from `data` instead of
the top-level object.
```

## Atomic commits

One logical change per commit. Signs a diff needs splitting: a feature and
an unrelated fix, formatting mixed with logic, two scopes with no relation.
Stage by path (`git add src/auth/`) and commit each group separately.
