# Changelog

## 1.0.0

- Conventional Commits flow: inspect, split into atomic commits, write,
  clean, validate, verify.
- Strips AI attribution (Claude, Copilot, ChatGPT/OpenAI, Cursor, Codex,
  Gemini) from commits and PR text; keeps human co-authors.
- Writes in the language configured in Claude Code (`language` setting),
  with spec tokens kept in English.
- Optional `commit-msg` hook (standalone copy, chains an existing hook,
  `--strip-only` mode).
- Documents the `attribution` setting to turn it off globally.
