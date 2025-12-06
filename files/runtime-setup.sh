#!/bin/bash

# Settings
GOOSE_VERSION="1.15.0"

# Check if initialization should run
INIT_FILE="/root/.local/init"
RUN_INIT=0

# Create init file directory if it doesn't exist
mkdir -p "$(dirname "$INIT_FILE")"

# Check if init file exists
if [ ! -f "$INIT_FILE" ]; then
  # First time execution
  echo "1" > "$INIT_FILE"
  RUN_INIT=1
elif [ -n "$SDEV_INIT_NOW" ]; then
  echo "1" > "$INIT_FILE"
  RUN_INIT=1
elif [ -n "$SDEV_NO_INIT" ]; then
  RUN_INIT=0
else
  # Check execution count
  COUNT=$(cat "$INIT_FILE")
  if [ "$COUNT" -ge 10 ]; then
    echo "1" > "$INIT_FILE"
    RUN_INIT=1
  else
    # Increment count
    echo $((COUNT + 1)) > "$INIT_FILE"
  fi
fi

# Only run initialization if conditions are met
if [ "$RUN_INIT" -eq 1 ]; then
  source /root/.bashrc.env
  pipx install --include-deps neovim
  npm install -g neovim prettier @modelcontextprotocol/server-filesystem mcp-server-commands @charmland/crush @google/gemini-cli
  nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
  rm /root/.config/mcphub/servers.json
  ln -s /root/server_config.json /root/.config/mcphub/servers.json

  # Goose install - only trigger in case this version isn't already installed
  if ! command -v goose &> /dev/null || [ "$(goose --version 2>/dev/null || echo '')" != "${GOOSE_VERSION}" ]; then
    curl -sLf "https://github.com/block/goose/releases/download/v${GOOSE_VERSION}/goose-x86_64-unknown-linux-gnu.tar.bz2" --output "/tmp/goose_install"
    tar -xjf "/tmp/goose_install" -C "/root/.local/bin"
  fi
fi
