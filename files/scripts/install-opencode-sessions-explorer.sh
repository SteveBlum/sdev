#!/usr/bin/env bash
#
# Clones/updates SteveBlum/opencode-sessions-explorer, builds it, and drops
# the bundled entrypoint directly into OpenCode's global plugin directory.
#
# OpenCode v2.0.26's `plugins`/`plugin` config array cannot load local paths —
# a file path is rejected ("configured plugin path must be a directory") and a
# directory path is silently ignored. Its ~/.config/opencode/plugins/
# auto-discovery also silently ignores package *subdirectories* in this
# release. The only mechanism that reliably loads a local, unpublished build
# is a single .js/.ts file placed directly in ~/.config/opencode/plugins/.
#
# Usage:
#   install-opencode-sessions-explorer.sh [src_dir] [plugins_dir]
#     src_dir     where to clone/build the source (default: /root/Git/opencode-sessions-explorer)
#     plugins_dir OpenCode's global plugin directory (default: /root/.config/opencode/plugins)
set -euo pipefail

REPO_URL="https://github.com/SteveBlum/opencode-sessions-explorer.git"
SRC_DIR="${1:-/tmp/opencode-sessions-explorer}"
PLUGINS_DIR="${2:-/root/.config/opencode/plugins}"

if [ -d "$SRC_DIR/.git" ]; then
    git -C "$SRC_DIR" pull --ff-only || git -C "$SRC_DIR" pull
else
    git clone "$REPO_URL" "$SRC_DIR"
fi

(cd "$SRC_DIR" && bun install && bun run build)

mkdir -p "$PLUGINS_DIR"
cp "$SRC_DIR/dist/plugin.js" "$PLUGINS_DIR/opencode-sessions-explorer.js"
echo "[+] Installed opencode-sessions-explorer: $PLUGINS_DIR/opencode-sessions-explorer.js"
