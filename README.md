# prestashop-experts

Claude Code plugin with **two expert agents** for daily PrestaShop freelance work, plus a curated knowledge base both agents consult before answering.

| Agent | Domain | KB |
|---|---|---|
| `panda-expert` | Panda theme by SunnyToo, `st*` modules, Easy Builder, SunnyToo demos | `skills/panda-kb/references/` — 118 markdown files |
| `prestashop-expert` | PrestaShop 8/9 core: themes parent-child, Symfony BO, Twig, Smarty, hooks, modules, install vs distribution, migration 8→9 | `skills/prestashop-kb/references/` — 79 markdown files |

Both agents are CWD-first: they always check the current project source before relying on KB snapshots, and they never edit the parent theme — only the child.

---

## Install

In Claude Code:

```
/plugin install educlopez/prestashop-experts
```

The plugin is private. You need read access on the GitHub repo first (`gh repo view educlopez/prestashop-experts` should succeed).

After install, both agents auto-register. Invoke them in two ways:

1. Direct mention: `@panda-expert` or `@prestashop-expert`.
2. Via the Task tool — Claude Code auto-routes by the description.

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

---

## What's in the KB

### panda-kb (`skills/panda-kb/references/`)

```
docs/         # 26 docs oficiales SunnyToo (shallow — imágenes no capturadas)
modules/      # 58 fiches generadas desde source de Panda 2.9.2
demos/        # 22 demos oficiales catalogadas
easybuilder/  # 6 docs del track Easy Builder (paid, opcional)
                01-widgets-catalog.md      # 31 widgets genéricos
                04-bridge-trans-panda.md   # 20 widgets PS-aware
forum/        # placeholder (diferido)
_agent/       # README de la KB + panda-expert system prompt original
README.md
00-Research-Report.md
```

### prestashop-kb (`skills/prestashop-kb/references/`)

```
themes/             # 13 docs — theme.yml, parent-child, template inheritance, Hummingbird v2 decision matrix
modules/            # 11 docs — config.xml, controllers, services.yml, lifecycle, hooks-in-modules
hooks/              # 3 docs — overview + listings
smarty/             # 40 docs — Smarty + PS extensions ({l}, {hook}, {widget})
install/            # 1 doc — source-vs-distribution.md (PS 9 clone vs zip)
version-migration/  # 8 docs — PS 8 → 9, Symfony/Twig BO, upgrade process
README.md
```

---

## Updating the KB

The canonical KB lives in Eduardo's Obsidian vault. To resync:

```bash
cd ~/Developer/tools/prestashop-experts
./scripts/sync-from-vault.sh
git add -A
git commit -m "chore: sync KB"
git push
```

The script:
1. Wipes `skills/*/references/` and rebuilds fresh from the vault.
2. Scrubs any author-local absolute paths so the KB is self-contained.
3. Reports file counts and any remaining unscrubbed paths.

Override the source location with `PANDA_KB_SOURCE=/path/to/Panda\ Knowledge\ Base ./scripts/sync-from-vault.sh` if your vault lives elsewhere.

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

---

## License

Proprietary — see [LICENSE](./LICENSE). Access is limited to authorized collaborators with valid PrestaShop / Panda / Easy Builder licenses where applicable.
