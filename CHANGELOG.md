# Changelog — Mivtra Craft

## 1.0.2

- `install.ps1` installs directly, with nothing to upload by hand: the plugin in Claude Code
  when it is found (also the CLI bundled with the Claude desktop app), otherwise personal skills
  in `~/.claude/skills`. It checks the result, removes duplicate copies, and records what it
  installed so `-Uninstall` removes exactly that. The zip for claude.ai chat is now opt-in (`-Zip`).

## 1.0.1

- The plugin now sits at the repository root, so GitHub's "Download ZIP" and the release zip
  both upload to the Claude app (the 1.0.0 layout failed with "plugin.json must be at
  .claude-plugin/plugin.json").
- `install.ps1`: one PowerShell command installs or updates the plugin in Claude Code and saves
  the zip for the Claude app; `-Uninstall` removes it.
- Each release carries `mivtra-craft.zip`.

## 1.0.0

First public release: one plugin, `mivtra-craft`, nine skills.

- `code` — entry point: routes every task to its skill, code, security and review rules.
- `product` — plan, project memory, product layer (About, licensing, backups, demo data, login,
  roles, installer, signed updates), printing, packaging.
- `design` — one identity for WPF and web: RTL/LTR, light + dark, shell, login, About, motion,
  alignment, responsive fit.
- `studio` — Arabic posts, ads, designs, short video and voiceover for the Gulf market.
- `audit`, `api`, `tests`, `office`, `it` — audits, API design, unit tests, Office documents,
  plant IT.
- Owner decisions are asked as choices, never as typed answers.
- Brand values are placeholders filled once in `skills/code/references/brand.md`.
