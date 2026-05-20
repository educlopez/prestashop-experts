#!/usr/bin/env bash
# validate.sh
# Pre-release sanity checks for the prestashop-experts plugin. Fails fast on:
#   - parent_theme: leftovers in KB (the correct field is `parent:`)
#   - absolute /Users/eduardocalvolopez paths in skills/
#   - plugin.json / marketplace.json / .release-please-manifest.json version mismatch
#   - invalid JSON in manifests
#   - missing required fields in agent frontmatter

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

EXIT_CODE=0
fail() {
  echo "  ❌ $1"
  EXIT_CODE=1
}
ok() {
  echo "  ✅ $1"
}

echo "==> Validating prestashop-experts plugin"
echo ""

# 1) parent_theme: leftovers (should only appear in 'no parent_theme:' context)
echo "[1/6] parent_theme: leftovers in KB..."
bad_files=$(
  grep -rln "parent_theme:" skills/ 2>/dev/null \
    | while read -r f; do
        # If `parent_theme:` appears in a line that ALSO contains a "don't use"
        # word (no, not, never, wrong, incorrect, deprecated, instead), treat
        # it as educational context and skip. Anything left is a real bug.
        leftover=$(grep -n "parent_theme:" "$f" | grep -ivE '\b(no|not|never|wrong|incorrect|deprecated|instead)\b' || true)
        if [[ -n "$leftover" ]]; then
          echo "$f"
        fi
      done
)
if [[ -z "$bad_files" ]]; then
  ok "No incorrect 'parent_theme:' references in skills/"
else
  fail "Found incorrect 'parent_theme:' in:"
  echo "$bad_files" | sed 's/^/      /'
fi

# 2) Absolute /Users/eduardocalvolopez paths in skills/references
echo "[2/6] Absolute /Users paths in skills/*/references/..."
abs_paths=$(grep -rln "/Users/eduardocalvolopez" skills/*/references/ 2>/dev/null || true)
if [[ -z "$abs_paths" ]]; then
  ok "No absolute /Users paths in KB references"
else
  fail "Absolute paths found in KB (should be scrubbed by sync-from-vault.sh):"
  echo "$abs_paths" | sed 's/^/      /'
fi

# 3) Version sync across plugin.json / marketplace.json / manifest
echo "[3/6] Version sync across manifests..."
plugin_v=$(grep -m1 '"version"' .claude-plugin/plugin.json | sed -E 's/.*"version": *"([^"]+)".*/\1/')
marketplace_meta_v=$(grep -A3 '"metadata"' .claude-plugin/marketplace.json | grep '"version"' | head -1 | sed -E 's/.*"version": *"([^"]+)".*/\1/')
marketplace_plugin_v=$(grep -A20 '"plugins"' .claude-plugin/marketplace.json | grep '"version"' | head -1 | sed -E 's/.*"version": *"([^"]+)".*/\1/')
manifest_v=$(grep '"."' .release-please-manifest.json | sed -E 's/.*"\.": *"([^"]+)".*/\1/')

if [[ "$plugin_v" == "$marketplace_meta_v" ]] \
   && [[ "$plugin_v" == "$marketplace_plugin_v" ]] \
   && [[ "$plugin_v" == "$manifest_v" ]]; then
  ok "All versions synced at $plugin_v"
else
  fail "Version mismatch:"
  echo "      plugin.json:                $plugin_v"
  echo "      marketplace.json metadata:  $marketplace_meta_v"
  echo "      marketplace.json plugin:    $marketplace_plugin_v"
  echo "      release-please manifest:    $manifest_v"
fi

# 4) JSON syntax validity
echo "[4/6] JSON syntax..."
json_errors=0
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json .release-please-manifest.json release-please-config.json; do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    : # silent ok
  else
    fail "Invalid JSON in $f"
    json_errors=$((json_errors + 1))
  fi
done
if [[ "$json_errors" -eq 0 ]]; then
  ok "All JSON files parse cleanly"
fi

# 5) Agent frontmatter has required fields
echo "[5/6] Agent frontmatter completeness..."
agent_errors=0
for agent in agents/*.md; do
  for field in name description tools model color; do
    if ! head -10 "$agent" | grep -qE "^${field}:"; then
      fail "Missing field '${field}:' in $agent"
      agent_errors=$((agent_errors + 1))
    fi
  done
done
if [[ "$agent_errors" -eq 0 ]]; then
  ok "All agents have name, description, tools, model, color"
fi

# 6) Plugin name consistency across manifests
echo "[6/6] Plugin name consistency..."
plugin_name=$(grep -m1 '"name"' .claude-plugin/plugin.json | sed -E 's/.*"name": *"([^"]+)".*/\1/')
mp_owner_name=$(grep -A2 '"plugins"' .claude-plugin/marketplace.json | grep '"name"' | head -1 | sed -E 's/.*"name": *"([^"]+)".*/\1/')
if [[ "$plugin_name" == "$mp_owner_name" ]] && [[ "$plugin_name" == "prestashop-experts" ]]; then
  ok "Plugin name 'prestashop-experts' consistent across manifests"
else
  fail "Plugin name inconsistency: plugin.json='$plugin_name', marketplace.json='$mp_owner_name'"
fi

echo ""
if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "==> All checks passed ✅"
else
  echo "==> Validation FAILED ❌ — fix the issues above before releasing."
fi

exit "$EXIT_CODE"
