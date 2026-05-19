---
tags: [kb, panda, agent, canonical]
---

# _agent/

**Fuente de verdad del system prompt del agente `panda-expert`.**

> [!warning] Este es el canónico
> Edita `panda-expert.md` en esta carpeta, no en `~/.claude/agents/`. Luego propaga con el comando del paso 2 de [[SETUP-NEW-MACHINE]].

## ¿Por qué aquí?

`~/.claude/agents/` NO está sincronizado por iCloud. Mantener la copia maestra dentro del vault nos da:
- Versionado via Obsidian (histórico en `.obsidian/trash` o git si configuras).
- Portabilidad automática entre máquinas via iCloud.
- Un único sitio donde Eduardo busca cuando quiere tunear el prompt.

## Flujo de edición

1. Edita `panda-expert.md` aquí.
2. En cada máquina donde uses el agente:
   ```bash
   cp "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain/Resources/Panda Knowledge Base/_agent/panda-expert.md" \
      ~/.claude/agents/panda-expert.md
   # si el username no es eduardocalvolopez, re-aplica el sed del SETUP
   ```
3. Reinicia la sesión de Claude Code para que recargue el agente.
