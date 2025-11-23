#!/bin/bash
npm config set prefix /root/.npm
echo "export PATH=\"/root/.npm/bin:$PATH\"" > /root/.bashrc.env
chmod +x /root/.bashrc.env
pipx install --include-deps neovim
npm install -g neovim prettier @modelcontextprotocol/server-filesystem mcp-server-commands @charmland/crush
