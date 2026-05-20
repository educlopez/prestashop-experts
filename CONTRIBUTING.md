# Contributing to prestashop-experts

Thanks for the interest. The plugin is maintained by Eduardo Calvo (educlopez). Compañeros and external contributors are welcome — read this first to know how the moving parts fit together.

---

## Repository shape

```
.
├── .claude-plugin/
│   ├── plugin.json              # plugin manifest (name, version, license)
│   └── marketplace.json         # marketplace entry for /plugin install
├── .github/
│   └── workflows/
│       ├── release-please.yml   # automated release PRs
│       └── validate.yml         # CI checks on every push and PR
├── agents/
│   ├── panda-expert.md          # Panda + Easy Builder + st* modules
│   └── prestashop-expert.md     # PS 8/9 core (Symfony, Smarty, hooks, migration)
├── commands/
│   ├── panda.md                 # /prestashop-experts:panda slash command
│   └── ps.md                    # /prestashop-experts:ps slash command
├── skills/
│   ├── panda-kb/
│   │   ├── SKILL.md             # skill description + KB layout
│   │   └── references/          # 120 md files — fiches, docs, demos, easybuilder
│   └── prestashop-kb/
│       ├── SKILL.md
│       └── references/          # 82 md files — themes, hooks, smarty, modules, migration
├── scripts/
│   ├── sync-from-vault.sh       # syncs KB from Eduardo's Obsidian vault
│   └── validate.sh              # pre-release sanity checks
├── CHANGELOG.md                 # managed by release-please
├── README.md
├── LICENSE                      # MIT
└── release-please-config.json
```

---

## The two sources of truth

- **The plugin tree** (this repo) is what compañeros install via `/plugin install prestashop-experts@prestashop-experts`. It must always be self-contained and validated.
- **Eduardo's Obsidian vault** (`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain/Resources/Panda Knowledge Base/`) is the canonical KB authoring environment. Vault → plugin via `scripts/sync-from-vault.sh`.

If you don't have the vault (most contributors), edit files directly in `skills/*/references/` and open a PR. Eduardo will fold the changes back into the vault.

---

## Workflow

### Quick fix in a fiche or doc

1. Find the file in `skills/panda-kb/references/` or `skills/prestashop-kb/references/`.
2. Edit, commit using **Conventional Commits** (see below).
3. Push and open a PR. CI will validate.
4. When merged, release-please will queue a release PR with the version bump.

### New module fiche

Place under `skills/panda-kb/references/modules/<module-name>.md`. Mirror the frontmatter shape of existing fiches:

```markdown
---
module_name: stnewmodule
display_name: New Module
version: 1.0.0
panda_version: 2.9.2
ps_version: [8, 9]
category: content
hooks: [displayX, actionY]
hooks_count: 2
is_configurable: true
files_count: 12
loc: 800
author: SUNNYTOO.COM
tags: [panda, module, content]
---

# Display Name

> [!info] Panda module
> **Category:** ... · **Version:** ... · **Hooks:** N · **LOC:** ...

## Purpose
...

## Hooks registered
...
```

### New KB doc (themes, smarty, version-migration, etc.)

Place under `skills/prestashop-kb/references/<topic>/<name>.md` with frontmatter:

```markdown
---
title: Short title
source: where the info came from (devdocs URL or 'extrapolation from X')
ps_version: [8, 9]
tags: [topic, ...]
last-updated: YYYY-MM-DD
---

# Title
...
```

### Tweak agent behavior

System prompts are in `agents/panda-expert.md` and `agents/prestashop-expert.md`. Both have strict YAML frontmatter:

```yaml
---
name: <agent-name>
description: <single-line trigger description>
tools: Read, Grep, Glob, Bash
model: sonnet
color: orange | blue
---
```

**Examples and operational rules live in the markdown body**, not in the frontmatter. The validator in `scripts/validate.sh` checks the required fields are present.

---

## Conventional Commits (required)

Releases are automated by [release-please](https://github.com/googleapis/release-please). Use these commit prefixes:

| Prefix | Effect |
|---|---|
| `feat: …` | Minor version bump (`0.1.x` → `0.2.0`) |
| `fix: …` / `refactor: …` / `perf: …` / `docs: …` | Patch bump |
| `chore: …` / `style: …` / `ci: …` / `test: …` / `build: …` | No bump (hidden from CHANGELOG) |
| `feat!: …` or `BREAKING CHANGE:` in body | Major bump (`0.x.y` → `1.0.0`) |

Scopes are optional but recommended: `feat(kb): …`, `fix(agents): …`, `feat(commands): …`.

After a `feat:` or `fix:` PR is merged to `main`, release-please will open or update a Release PR. Merging that PR creates the tag, the GitHub Release, and bumps the version in `plugin.json` + `marketplace.json` automatically.

---

## Before pushing

Run the validator locally:

```bash
./scripts/validate.sh
```

It checks:

1. No `parent_theme:` leftovers (correct field is `parent:`).
2. No absolute `/Users/eduardo…` paths in `skills/*/references/`.
3. Versions synced across `plugin.json`, `marketplace.json`, and `.release-please-manifest.json`.
4. All JSON manifests parse cleanly.
5. All agents have required frontmatter fields (`name`, `description`, `tools`, `model`, `color`).
6. Plugin name consistency across manifests.

CI runs the same script on every push and PR.

---

## Updating the KB from the vault (maintainer)

Only Eduardo (or anyone with the vault) runs this:

```bash
./scripts/sync-from-vault.sh
```

The script:
1. Stages to a tmp directory (atomic — never destroys the plugin tree on partial failure).
2. Scrubs author-local absolute paths.
3. Validates the stage (≥ 50 panda md + ≥ 30 ps md) before swapping into `skills/*/references/`.
4. Reports file counts.

Override the source location with `PANDA_KB_SOURCE=/path/to/Panda\ Knowledge\ Base ./scripts/sync-from-vault.sh`.

---

## Reporting an issue

Open an issue at https://github.com/educlopez/prestashop-experts/issues with:

- What you asked the agent
- What it answered
- What you expected
- The Panda version + PS version of the project (if applicable)
- Whether the wrong info appears in a fiche/doc — point to the file

Bug reports about hallucinated hooks or invented module options are especially welcome — those go straight into the system prompt as anti-examples.
