# prestashop-experts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/educlopez/prestashop-experts?label=release)](https://github.com/educlopez/prestashop-experts/releases)
[![Changelog](https://img.shields.io/badge/changelog-keep%20a%20changelog-orange)](./CHANGELOG.md)

Claude Code plugin with **two expert agents** for daily PrestaShop freelance work, plus a curated knowledge base both agents consult before answering.

| Agent | Domain | KB size |
|---|---|---|
| `panda-expert` | Panda theme by SunnyToo, `st*` modules, Easy Builder, SunnyToo demos | 120 md files |
| `prestashop-expert` | PrestaShop 8/9 core: themes, parent-child, Symfony BO, Twig, Smarty, hooks, modules, install, migration 8→9 | 82 md files |

Both agents are **CWD-first**: they always inspect the current project source before relying on KB snapshots, and they never edit the parent theme — only the child.

---

## Install

In Claude Code:

```
/plugin marketplace add educlopez/prestashop-experts
/plugin install prestashop-experts@prestashop-experts
/reload-plugins
```

After install, both agents auto-register. Invoke them in two ways:

1. Direct mention: `@panda-expert` or `@prestashop-expert`.
2. Via the Task tool — Claude Code auto-routes by the agent description.

### Updating

```
/plugin marketplace update prestashop-experts
/plugin uninstall prestashop-experts@prestashop-experts
/plugin install prestashop-experts@prestashop-experts
/reload-plugins
```

See the [CHANGELOG](./CHANGELOG.md) for what's new in each release.

---

## When to use which

```
PrestaShop question
        │
        ▼
Is it about the Panda theme specifically? ──── yes ──▶ panda-expert
        │
        no
        │
        ▼
Is it about a `st*` module / SunnyToo / Easy Builder? ── yes ──▶ panda-expert
        │
        no
        │
        ▼
Is it about a storefront layout you'd render with Panda? ─ yes ──▶ panda-expert
        │
        no
        │
        ▼
       prestashop-expert (Symfony BO, Twig, Smarty, hooks, modules, themes core, migration)
```

Examples:

- "¿Qué módulo de Panda uso para un megamenu con imágenes de categoría?" → `panda-expert`.
- "¿Cómo override el template `product.tpl` sin tocar el padre?" → `panda-expert` (project lives in Panda).
- "¿Qué cambia en hooks de PS 8 a PS 9?" → `prestashop-expert`.
- "Cloné PS 9 source y tengo `install-dev/` en vez de `install/`. ¿Qué hago?" → `prestashop-expert`.
- "Hummingbird vs Panda para un cliente con compliance EAA" → `prestashop-expert` (decision matrix).
- "¿Qué demo de Panda como base para web de moda?" → `panda-expert`.

> **Note**: `stats*` modules (`statsbestcategories`, `statsbestcustomers`, etc.) are PS core, **not** Panda. The agents will defer those questions to `prestashop-expert`.

---

## What's in the KB

### panda-kb (`skills/panda-kb/references/`)

```
docs/         # 26 docs oficiales SunnyToo (shallow — imágenes no capturadas)
modules/      # 58 fiches generadas desde source de Panda 2.9.2
              # incluye stbanner, stmegamenu, stbrandsslider, stfeaturedslider,
              # stblog (+ 10 sub-módulos), stthemeeditor, steasybuilder,
              # steasy_trans_panda, etc.
demos/        # 22 demos oficiales catalogadas
easybuilder/  # 6 docs del track Easy Builder (paid, opcional)
              #   01-widgets-catalog.md      # 31 widgets genéricos
              #   04-bridge-trans-panda.md   # 20 widgets PS-aware
forum/        # placeholder (diferido)
_agent/       # README de la KB + panda-expert system prompt original
README.md
00-Research-Report.md
```

### prestashop-kb (`skills/prestashop-kb/references/`)

```
themes/             # 14 docs — theme.yml, parent-child, template inheritance,
                    # Hummingbird v2 decision matrix, themes folder layout PS 9,
                    # recovery protocol for parent edits
modules/            # 11 docs — config.xml, controllers, services.yml, lifecycle,
                    # hooks-in-modules
hooks/              # 3 docs — overview + listings
smarty/             # 40 docs — Smarty + PS extensions ({l}, {hook}, {widget})
install/            # 1 doc — source-vs-distribution.md (PS 9 clone vs zip)
version-migration/  # 9 docs — PS 8 → 9, Symfony/Twig BO, upgrade process,
                    # custom module migration
README.md
```

---

## Operating principles (both agents)

1. **Read first, answer second.** Always consult the KB before responding.
2. **CWD is authoritative** for the active client project. The KB is a snapshot of Panda 2.9.2 / PS official docs — the project may diverge.
3. **Never edit the parent theme.** All visual changes go in the child theme.
4. **Distinguish source of every claim** with icons:
   - ✅ Confirmed in KB fiche or doc.
   - 🔍 Read from project source in CWD.
   - ⚠️ Inferred / needs validation.
   - ❌ Not in KB / unknown.
5. **Never run destructive commands** without confirmation. Local first.
6. **Hooks recommendations** must come from the fiche `hooks:` array or be flagged with 🔍 + source path. No invented hooks.
7. **Child theme detection** — the field is `parent: <theme-name>` in `config/theme.yml`, **not** `parent_theme:`. Child theme folder name does NOT need to follow `<parent>_child` convention.

---

## Contributing

The canonical KB lives in Eduardo's Obsidian vault. To resync the plugin tree from the vault:

```bash
cd ~/Developer/tools/prestashop-experts
./scripts/sync-from-vault.sh
```

The script:

1. **Stages** to a tmp directory.
2. Scrubs author-local absolute paths so the KB is self-contained.
3. Validates the stage (>= 50 panda md + >= 30 ps md) before swapping into the plugin tree — aborts cleanly on partial copy.
4. Reports file counts and any remaining unscrubbed paths.

Override the vault location with `PANDA_KB_SOURCE=/path/to/Panda\ Knowledge\ Base ./scripts/sync-from-vault.sh`.

### Releases

Releases are automated via [release-please](https://github.com/googleapis/release-please). Just commit using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

- `feat: …` → minor bump (`0.1.x` → `0.2.0`)
- `fix: …` / `refactor: …` / `perf: …` / `docs: …` → patch bump
- `chore: …` / `style: …` / `ci: …` / `test: …` / `build: …` → no bump

On every push to `main`, a Release PR is opened/updated with the new version + CHANGELOG entry. Merging the PR creates a tagged GitHub Release and bumps the version in `plugin.json` + `marketplace.json` automatically.

---

## License

[MIT](./LICENSE). See the LICENSE file for notes on the bundled documentation about Panda and Easy Builder (commercial products by SunnyToo — the KB describes their architecture from legitimate use, no source code is redistributed).
