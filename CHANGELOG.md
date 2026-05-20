# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases are managed automatically by [release-please](https://github.com/googleapis/release-please) from Conventional Commits.

## [0.1.2] - 2026-05-20

### Features

- **KB**: new `prestashop-kb/themes/themes-folder-layout-ps9.md` documenting the PS 9 `themes/` folder shape (`_core/js/`, `_libraries/font-awesome/`, `debug.tpl`, `javascript.tpl`, `package.json`, plus `classic/`/`hummingbird/`/`panda/`/child themes). Distinguishes real themes from shared resources.
- **KB**: new fiche `panda-kb/modules/steasybuilder.md` for Easy Builder (paid, optional, Elementor-based, ~36 MB module; incompatibilities with `jscomposer`/`creativeelements`/`crazyelements`).
- **KB**: new fiche `panda-kb/modules/steasy_trans_panda.md` for the PS-aware widgets bridge (20 widgets, depends on `steasybuilder`).

### Bug Fixes

- **CRITICAL**: child theme field in `theme.yml` is **`parent:`**, not `parent_theme:`. The PrestaShop devdocs were correct, but the panda-expert system prompt, `recovery-parent-edits.md`, and `prestashop-kb/SKILL.md` had the wrong name. Fixed in v0.1.2 — verified against a real PS 9.1.0 + Panda 2.9.2 project.
- **panda-expert system prompt** — rule 3bis: hooks recommendations MUST come from the fiche `hooks:` array or be flagged with 🔍 + source path. Hallucinated hooks observed in dogfood (e.g. `displayNavFullWidth`, `displayTop`, `displayFooterBefore`) are now explicitly called out as anti-examples. Real hooks confirmed: `stbrandsslider` → `displayHomeBottom`; `stmegamenu` → `displayHeader`, `displayMainMenu`, `displayLeftColumn`, `displaySideBar`, `displayMobileBarLeft`.
- **panda-expert system prompt** — rule 3ter: `stats*` modules are PS core, not Panda. The agent now defers them to `prestashop-expert` instead of treating them as Panda-specific.
- **panda-expert system prompt** — child theme name does NOT need to follow `<parent>_child`. Names like `panda-v2_child`, `mi-tema-custom` are valid; the relationship is declared in `config/theme.yml`, not in folder naming.

### Refactoring

- **`scripts/sync-from-vault.sh`** is now atomic: stages to a tmp directory and only swaps into the plugin tree if the stage validates (>= 50 panda md + >= 30 ps md). Prior version would `rm -rf` the destination before populating, leaving an empty KB if iCloud TCC blocked a mid-script read. The new version aborts cleanly with the plugin tree intact.

## [0.1.1] - 2026-05-20

### Features

- **KB**: new `prestashop-kb/version-migration/module-migration-8-to-9.md` — walkthrough for migrating a **custom module** from PS 8 to PS 9 (PHP 8.1+, `services.yml`, when to migrate BO controllers to Symfony vs leave legacy, hooks compatibility, deprecation checklist).
- **KB**: new `prestashop-kb/themes/recovery-parent-edits.md` — recovery protocol when a client edited the parent theme directly. 7-step protocol covering diff capture, child creation, override move, parent restore, cache invalidation, multi-shop, and `theme.yml` cases.

### Bug Fixes

- **System prompts** — both agents now enforce the `✅🔍⚠️❌` icon scheme on the first line of every response, with concrete examples. Opening with `Procedencia:` / `Fuentes consultadas:` without the icons is now explicitly disallowed.
- **System prompts** — KB citations must use paths relative to `references/` (e.g. `panda-kb/modules/stmegamenu.md`), never absolute paths (e.g. `/Users/.../skills/panda-kb/references/...`).
- **System prompts** — when the CWD is not a PrestaShop project and the question is operational, agents now ask for the project path before answering. Conceptual questions still get a direct answer.

## [0.1.0] - 2026-05-19

### Features

- Initial release. Two expert agents:
  - **`panda-expert`** (model: sonnet, color: orange) — SunnyToo Panda theme + Easy Builder. KB: 118 markdown files (`docs/`, `modules/`, `demos/`, `easybuilder/`, `forum/`, `_agent/`).
  - **`prestashop-expert`** (model: sonnet, color: blue) — PrestaShop 8 and 9 core. KB: 79 markdown files (`themes/`, `modules/`, `hooks/`, `smarty/`, `install/`, `version-migration/`).
- Both agents are CWD-first: they inspect the active client project source before relying on KB snapshots, and they never edit the parent theme — only the child.
- **`scripts/sync-from-vault.sh`** — syncs the curated KB from Eduardo's Obsidian vault into the plugin's `skills/*/references/` folders. Scrubs author-local absolute paths so the KB is self-contained. Uses a TCC-safe `find` + `cat` loop to work around macOS iCloud restrictions on `cp -R`/`rsync`/`tar`/`ditto`.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` properly configured for `/plugin install` discovery from Claude Code.
