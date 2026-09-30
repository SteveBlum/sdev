#!/usr/bin/env bash
#
# patch-opencode-sessions-explorer.sh
#
# Applies two fixes to opencode-sessions-explorer@0.1.4:
#
# 1. "datatype mismatch" SQLite errors when tools are invoked without explicit
#    limit/top arguments (OpenCode does not apply Zod defaults).
# 2. "Plugin must export a default definition with an id and an effect or setup
#    function." load failure under OpenCode V2 (err_1bfe2d0d). V2's loader
#    requires the default export to be a definition object ({ id, setup } or
#    { id, effect }), but the package still default-exports the legacy V1
#    factory function. Wraps it using OpenCode's documented V1/V2 compat shape
#    (https://opencode.ai/v2/docs/build/plugins/migrate-v1#support-v1-and-v2-from-one-package)
#    so V2 loads it via `server()` while still satisfying the `id`/`setup` schema.
#
# OpenCode can resolve this package into several cache locations at once
# (observed: ~/.cache/opencode/packages/opencode-sessions-explorer,
# ~/.cache/opencode/packages/opencode-sessions-explorer@latest, and
# ~/.cache/opencode/npm/opencode-sessions-explorer@latest/<timestamp>/...),
# and only one of them is the actual entrypoint a given server run loads.
# Rather than guessing, this script discovers and patches every copy it can
# find under the OpenCode cache directory, so whichever one gets loaded is
# already fixed.
#
# Usage:
#   patch-opencode-sessions-explorer.sh              # auto-discover under $HOME/.cache/opencode
#   patch-opencode-sessions-explorer.sh <file|dir>...  # patch specific file(s), or search specific dir(s)
#
set -euo pipefail

# Expected SHA256 hashes, one per known state of the file:
# - UNPATCHED_HASH: pristine opencode-sessions-explorer@0.1.4 release
# - LIMIT_PATCHED_HASH: patch 1 applied, patch 2 not yet applied (older runs of this script)
# - FULLY_PATCHED_HASH: both patches applied by this script
UNPATCHED_HASH="54394934436895fa9ff33bb1a3b5dba368355eee9f69c6a509bfae2f9fec6d76"
LIMIT_PATCHED_HASH="12f394b6f8446496ead5f7364a7c5ec75e234b959ee6508eada168c6dc234de7"
FULLY_PATCHED_HASH="9289d55100cd324fa0ea4716adc4ae10d789bb88fe579d56b8a4db43323822c1"

CACHE_ROOT="${OPENCODE_CACHE_HOME:-$HOME/.cache/opencode}"

patch_file() {
    local target="$1"

    if [ ! -f "$target" ]; then
        echo "[!] Target file not found: $target"
        return 0
    fi

    local current_hash
    current_hash=$(sha256sum "$target" | awk '{print $1}')

    if [ "$current_hash" = "$FULLY_PATCHED_HASH" ]; then
        echo "[+] Already fully patched, skipping: $target"
        return 0
    fi

    if [ "$current_hash" != "$UNPATCHED_HASH" ] && [ "$current_hash" != "$LIMIT_PATCHED_HASH" ]; then
        echo "[!] SHA256 mismatch for $target"
        echo "    Expected one of:"
        echo "      $UNPATCHED_HASH (pristine)"
        echo "      $LIMIT_PATCHED_HASH (limit patch already applied)"
        echo "    Actual:   $current_hash"
        echo "    Refusing to patch unknown file version."
        return 1
    fi

    if [ "$current_hash" = "$LIMIT_PATCHED_HASH" ]; then
        echo "[*] $target already has the limit patch applied. Applying default-export patch only..."
    else
        echo "[*] $target matched expected hash ($UNPATCHED_HASH). Applying patches..."
    fi

    python3 - "$target" "$current_hash" "$UNPATCHED_HASH" << 'EOF'
import sys

target = sys.argv[1]
current_hash = sys.argv[2]
unpatched_hash = sys.argv[3]

with open(target, "r", encoding="utf-8") as f:
    content = f.read()

def apply(replacements):
    global content
    for old, new in replacements:
        count = content.count(old)
        if count != 1:
            sys.stderr.write(f"Error: expected 1 match for pattern, found {count}\n")
            sys.exit(1)
        content = content.replace(old, new)

# Patch 1: default-argument fallbacks for limit/top (SQLite "datatype mismatch").
# Only needed starting from the pristine release; skip if already applied.
if current_hash == unpatched_hash:
    apply([
        # 1. list_sessions: limit fallback
        ("const limit = args.limit;", "const limit = args.limit ?? 20;"),

        # 2. list_tool_failures: limit slice fallback
        ("sort((a, b) => b.count - a.count).slice(0, args.limit)",
         "sort((a, b) => b.count - a.count).slice(0, args.limit ?? 20)"),

        # 3. list_tool_failures: limit param fallback
        ("ORDER BY count DESC\n           LIMIT ?`;\n      }\n      params.push(args.limit);",
         "ORDER BY count DESC\n           LIMIT ?`;\n      }\n      params.push(args.limit ?? 20);"),

        # 4. search_sessions_meta: limit param fallback
        ("ORDER BY s.time_updated DESC, s.id DESC\n         LIMIT ?`;\n      params.push(args.limit + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > args.limit) {",
         "ORDER BY s.time_updated DESC, s.id DESC\n         LIMIT ?`;\n      params.push((args.limit ?? 20) + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > (args.limit ?? 20)) {"),

        # 5. search_tool_calls: limit param fallback
        ("ORDER BY p.time_created DESC, p.id DESC\n         LIMIT ?`;\n      params.push(args.limit + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > args.limit) {",
         "ORDER BY p.time_created DESC, p.id DESC\n         LIMIT ?`;\n      params.push((args.limit ?? 10) + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > (args.limit ?? 10)) {"),

        # 6. session_timeline: limit param fallback
        ("ORDER BY p.time_created ASC, p.id ASC\n         LIMIT ?`;\n      params.push(args.limit + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > args.limit) {",
         "ORDER BY p.time_created ASC, p.id ASC\n         LIMIT ?`;\n      params.push((args.limit ?? 100) + 1);\n      const rows = stmt(sql).all(...params);\n      let hasMore = false;\n      if (rows.length > (args.limit ?? 100)) {"),

        # 7. session_timeline: max_summary_chars fallback
        ("const events = args.granularity === \"turns\" ? collapseTurns(rawEvents, args.max_summary_chars) : rawEvents;",
         "const events = args.granularity === \"turns\" ? collapseTurns(rawEvents, args.max_summary_chars ?? 200) : rawEvents;"),

        # 8. cost_by_project: top param fallback
        ("params.push(args.top);\n      const rows = stmt(sql).all(...params);",
         "params.push(args.top ?? 20);\n      const rows = stmt(sql).all(...params);")
    ])

# Patch 2: OpenCode V2 rejects a bare factory-function default export
# ("Plugin must export a default definition with an id and an effect or setup
# function.", err_1bfe2d0d). Wrap it in the documented V1/V2 compat shape: a
# definition object with `id` + a no-op `setup`, plus a `server()` method that
# V2 uses to run the legacy V1 factory function untouched.
apply([
    ("var plugin_default = OpencodeSessionsExplorerPlugin;\n"
     "export {\n"
     "  plugin_default as default,\n"
     "  OpencodeSessionsExplorerPlugin\n"
     "};\n",
     'var plugin_default = {\n'
     '  id: "opencode-sessions-explorer",\n'
     '  async setup() {\n'
     '  },\n'
     '  async server(input) {\n'
     '    return await OpencodeSessionsExplorerPlugin(input);\n'
     '  }\n'
     '};\n'
     'export {\n'
     '  plugin_default as default,\n'
     '  OpencodeSessionsExplorerPlugin\n'
     '};\n')
])

with open(target, "w", encoding="utf-8") as f:
    f.write(content)
EOF

    local new_hash
    new_hash=$(sha256sum "$target" | awk '{print $1}')
    if [ "$new_hash" = "$FULLY_PATCHED_HASH" ]; then
        echo "[+] Patch successfully applied and verified: $target"
        return 0
    else
        echo "[!] Warning: Patch applied but resulting hash ($new_hash) did not match expected ($FULLY_PATCHED_HASH): $target"
        return 1
    fi
}

# Build the list of files to patch.
declare -a targets=()

if [ "$#" -gt 0 ]; then
    for arg in "$@"; do
        if [ -d "$arg" ]; then
            while IFS= read -r -d '' found; do
                targets+=("$found")
            done < <(find "$arg" -type f -path "*/node_modules/opencode-sessions-explorer/dist/plugin.js" -print0 2>/dev/null)
        else
            targets+=("$arg")
        fi
    done
else
    if [ ! -d "$CACHE_ROOT" ]; then
        echo "[i] OpenCode cache directory not found: $CACHE_ROOT (nothing to patch yet, e.g. first container boot)."
        exit 0
    fi
    while IFS= read -r -d '' found; do
        targets+=("$found")
    done < <(find "$CACHE_ROOT" -type f -path "*/node_modules/opencode-sessions-explorer/dist/plugin.js" -print0 2>/dev/null)
fi

if [ "${#targets[@]}" -eq 0 ]; then
    echo "[i] No opencode-sessions-explorer plugin.js copies found under $CACHE_ROOT. Nothing to patch."
    exit 0
fi

status=0
for target in "${targets[@]}"; do
    patch_file "$target" || status=1
done

exit "$status"
