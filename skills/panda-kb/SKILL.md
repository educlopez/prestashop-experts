---
name: panda-kb
description: Curated knowledge base for the Panda theme by SunnyToo on PrestaShop 8 and 9 — 54 module fiches, 19 demos catalog, scraped official docs, and the Easy Builder track (steasybuilder + steasy_trans_panda). Use when answering questions about Panda-specific modules (`st*` prefix), SunnyToo widgets, Easy Builder layouts, or "what can Panda render". For PrestaShop platform-level questions (Symfony, Twig BO, Smarty syntax, hooks core, theme.yml mechanics, migration 8→9) use the `prestashop-kb` skill instead.
---

# Panda Knowledge Base

This skill exposes the curated Panda theme knowledge base bundled with the `prestashop-experts` plugin. The `panda-expert` agent consults this KB before answering, but any agent can read these files directly.

## When this skill is relevant

Load and read from this KB when the user mentions:

- The **Panda theme** by SunnyToo (any PrestaShop version).
- Any **`st*` module name** — `stmegamenu`, `ststickers`, `stblog`, `stthemeeditor`, `stmanufacturer`, `stcustomtext`, etc.
- **Easy Builder** / `steasybuilder` / `steasy_trans_panda` widgets, presets, admin controllers, or the PS-aware bridge.
- A SunnyToo **demo** ("ecommerce de moda", "tienda de tecnología", "alimentación", etc.).
- A storefront layout question phrased as "puede Panda hacer X" or "qué módulo Panda uso para Y".

Do NOT load for: PrestaShop core mechanics (use `prestashop-kb`), other themes (Classic, Warehouse, Leo, Hummingbird), or non-PrestaShop e-commerce.

## KB layout

```
references/
├── README.md                    # convenciones y índice de la KB
├── 00-Research-Report.md        # reconocimiento inicial Panda + URLs oficiales
├── docs/                        # 26 docs oficiales scrapeadas (shallow — imágenes no capturadas)
│   ├── _index.md
│   ├── _module-names.md
│   ├── faq.md
│   ├── getting-started.md
│   ├── theme-install.md
│   ├── theme-settings.md
│   ├── theme-customization.md
│   ├── modules-overview.md
│   └── module-*.md              # 12 módulos documentados oficialmente
├── modules/                     # 58 fiches generadas leyendo el source de Panda 2.9.2
│   ├── _index.md                # tabla maestra: módulo, hooks, LOC, configurable, BO own
│   ├── _by-category.md          # agrupado por blog/product/navigation/content/helpers
│   ├── README.md                # template de ficha
│   └── st*.md                   # una ficha por módulo Panda-específico (54+)
├── demos/                       # 22 demos catalogadas
├── easybuilder/                 # track SEPARADO — Easy Builder es paid opcional
│   ├── 00-overview.md
│   ├── 01-widgets-catalog.md    # 31 widgets genéricos del core EB
│   ├── 02-presets-catalog.md
│   ├── 03-admin-controllers.md
│   └── 04-bridge-trans-panda.md # 20 widgets PS-aware via steasy_trans_panda
└── forum/                       # placeholder — diferido a futuro
```

## How to use the KB

1. **Start with the index**: `modules/_index.md` for the master table; `modules/_by-category.md` to find by use case.
2. **Open the specific fiche** (`modules/stXXX.md`) for hooks, LOC, dependencies, and what the module does.
3. **Easy Builder questions** → `easybuilder/01-widgets-catalog.md` (31 generic widgets) + `easybuilder/04-bridge-trans-panda.md` (20 PS-aware widgets). Generic widgets need only `steasybuilder`; PS-aware widgets need **both** `steasybuilder` and `steasy_trans_panda`.
4. **"Which demo?"** → `demos/` catalog. Each demo is a reference configuration of modules.
5. **Official docs fallback**: `docs/` is shallow because the real configuration info lives in screenshots not captured. Use as last resort.

## Key facts to surface to agents

- Panda's `theme.yml` declares `compatibility.from: 1.7.1.0`, `to: ~` → supports PS 8 and PS 9 simultaneously.
- **`stthemeeditor` is the central configuration hub** (~25K LOC, 153 files). Most of the 54+ Panda modules do NOT have their own admin screen — they are configured via `stthemeeditor`. Only ~8 have a BO form of their own.
- **`stmegamenu` has 19 hooks** — it reacts to changes in categories, products, CMS, manufacturers, suppliers. The most hook-heavy module.
- **`stblog` has 10 sub-modules** that depend on the parent (archives, comments, editor, search, tags, etc.).
- **`stoverride`, `stupgrader`, `stxlfgenerator`** are infrastructure helpers (0 hooks).
- **`steasycontent`** is bundled in Panda (do not confuse with `steasybuilder` which is paid optional).

## Gaps to be honest about

- Module fiches show options as placeholder ("see .tpl and translations"). For real options in a specific project, read the source in the **current working directory** (`./modules/stX/`), not the KB.
- The 54 fiches were crystallized from Panda 2.9.2 distribution. If the CWD has Panda 2.9.3+ or a customized install, **the CWD is authoritative**.
- `docs/` content is text-only (screenshots not captured). Don't rely on `docs/` for step-by-step configuration.
- Demo↔module cross-reference is not yet indexed. For "which demo as base for fashion ecommerce" suggest `https://panda2.sunnytoo.com/select-demo.html`.

## Cross-skill pointer

For Panda's interaction with PrestaShop core mechanics (hooks lifecycle, parent-child theme cascade, Smarty syntax, migration 8→9), the platform knowledge lives in the sibling skill `prestashop-kb` and the agent `prestashop-expert`.
