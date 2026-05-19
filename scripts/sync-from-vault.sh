#!/usr/bin/env bash
# sync-from-vault.sh
# Sync the curated Panda + PrestaShop knowledge base from Eduardo's Obsidian
# vault into the plugin's skills/*/references/ folders, and scrub any
# author-local absolute paths so the resulting KB is self-contained.
#
# Run from the repo root: ./scripts/sync-from-vault.sh
#
# Idempotent: deletes destination references/ and re-copies fresh.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT_KB="${PANDA_KB_SOURCE:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain/Resources/Panda Knowledge Base}"

if [[ ! -d "$VAULT_KB" ]]; then
  echo "ERROR: vault KB not found at: $VAULT_KB" >&2
  echo "Override with PANDA_KB_SOURCE=/path/to/Panda\\ Knowledge\\ Base" >&2
  exit 1
fi

PANDA_DST="$REPO_ROOT/skills/panda-kb/references"
PS_DST="$REPO_ROOT/skills/prestashop-kb/references"

echo "==> Syncing from: $VAULT_KB"
echo "==> Panda dst:    $PANDA_DST"
echo "==> PS dst:       $PS_DST"

# Wipe destinations so removed files in vault are removed here too.
rm -rf "$PANDA_DST" "$PS_DST"
mkdir -p "$PANDA_DST" "$PS_DST"

# Copy file-by-file via `cat` to avoid macOS TCC issues with cp/rsync/tar/ditto
# on iCloud-protected paths. No metadata is preserved (we don't need any).
copy_tree() {
  local src="$1" dst="$2"
  # find + read loop: relative path, mkdir parent, cat the file.
  find "$src" \( -name '.DS_Store' -prune \) -o -type f -print0 \
    | while IFS= read -r -d '' f; do
        local rel="${f#$src/}"
        local target="$dst/$rel"
        mkdir -p "$(dirname "$target")"
        cat "$f" > "$target"
      done
}

# --- panda-expert KB ---
# theme Panda + Easy Builder + scraped docs + module fiches + demos
for sub in docs modules demos easybuilder forum _agent; do
  if [[ -d "$VAULT_KB/$sub" ]]; then
    mkdir -p "$PANDA_DST/$sub"
    copy_tree "$VAULT_KB/$sub" "$PANDA_DST/$sub"
  fi
done
# top-level orientation files
for f in README.md 00-Research-Report.md; do
  if [[ -f "$VAULT_KB/$f" ]]; then
    cat "$VAULT_KB/$f" > "$PANDA_DST/$f"
  fi
done

# --- prestashop-expert KB ---
# platform-level docs (Symfony, smarty, themes, hooks, modules, install, version-migration)
if [[ -d "$VAULT_KB/prestashop" ]]; then
  copy_tree "$VAULT_KB/prestashop" "$PS_DST"
fi

# --- scrub absolute paths so KB is self-contained ---
echo "==> Scrubbing absolute paths..."
scrub() {
  local target="$1"
  # Author's local prestashop setup mirror — KB shouldn't depend on it.
  find "$target" -type f -name '*.md' -print0 | xargs -0 sed -i '' -E \
    -e 's|/Users/eduardocalvolopez/Documents/prestashop/setup/[^ )"`]*|<source-archive>/|g' \
    -e 's|/Users/eduardocalvolopez/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain/Resources/Panda Knowledge Base/|<KB>/|g' \
    -e 's|/Users/eduardocalvolopez/|<HOME>/|g'
}
scrub "$PANDA_DST"
scrub "$PS_DST"

# --- report ---
panda_files=$(find "$PANDA_DST" -type f -name '*.md' | wc -l | tr -d ' ')
ps_files=$(find "$PS_DST" -type f -name '*.md' | wc -l | tr -d ' ')
remaining=$(grep -rl '/Users/eduardocalvolopez' "$PANDA_DST" "$PS_DST" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "Done."
echo "  panda-kb:       $panda_files markdown files"
echo "  prestashop-kb:  $ps_files markdown files"
echo "  remaining absolute /Users/eduardocalvolopez references: $remaining"
if [[ "$remaining" != "0" ]]; then
  echo "  (run: grep -rl /Users/eduardocalvolopez skills/  to inspect)"
fi
