#!/usr/bin/env bash
#
# patch-opencode-sessions-explorer.sh
#
# Fixes "datatype mismatch" SQLite errors in opencode-sessions-explorer when tools
# are invoked without explicit limit/top arguments (OpenCode does not apply Zod defaults).
#
set -euo pipefail

TARGET="${1:-/root/.cache/opencode/packages/opencode-sessions-explorer@latest/node_modules/opencode-sessions-explorer/dist/plugin.js}"

# Expected SHA256 hashes:
# - UNPATCHED_HASH: pristine opencode-sessions-explorer@0.1.4 release
# - PATCHED_HASH: already patched by this script
UNPATCHED_HASH="54394934436895fa9ff33bb1a3b5dba368355eee9f69c6a509bfae2f9fec6d76"
PATCHED_HASH="12f394b6f8446496ead5f7364a7c5ec75e234b959ee6508eada168c6dc234de7"

if [ ! -f "$TARGET" ]; then
    echo "[!] Target file not found: $TARGET"
    exit 0
fi

CURRENT_HASH=$(sha256sum "$TARGET" | awk '{print $1}')

if [ "$CURRENT_HASH" = "$PATCHED_HASH" ]; then
    echo "[+] Target already patched. Nothing to do."
    exit 0
fi

if [ "$CURRENT_HASH" != "$UNPATCHED_HASH" ]; then
    echo "[!] SHA256 mismatch for $TARGET"
    echo "    Expected: $UNPATCHED_HASH"
    echo "    Actual:   $CURRENT_HASH"
    echo "    Refusing to patch unknown file version."
    exit 1
fi

echo "[*] Target matched expected hash ($UNPATCHED_HASH). Applying patch..."

python3 - "$TARGET" << 'EOF'
import sys

target = sys.argv[1]

with open(target, "r", encoding="utf-8") as f:
    content = f.read()

replacements = [
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
]

for old, new in replacements:
    count = content.count(old)
    if count != 1:
        sys.stderr.write(f"Error: expected 1 match for pattern, found {count}\n")
        sys.exit(1)
    content = content.replace(old, new)

with open(target, "w", encoding="utf-8") as f:
    f.write(content)
EOF

NEW_HASH=$(sha256sum "$TARGET" | awk '{print $1}')
if [ "$NEW_HASH" = "$PATCHED_HASH" ]; then
    echo "[+] Patch successfully applied and verified."
else
    echo "[!] Warning: Patch applied but resulting hash ($NEW_HASH) did not match expected ($PATCHED_HASH)."
    exit 1
fi
