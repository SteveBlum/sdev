#!/bin/bash

# Check if initialization should run
INIT_FILE="/root/.local/init"
RUN_INIT=0

# Create a local copy of .npmrc
[ -f /root/.npmrc.host ] && cp /root/.npmrc.host /root/.npmrc

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
  [ -f /root/.bashrc.env ] && source /root/.bashrc.env
  ansible-playbook -i /root/ansible/inventory.ini /root/ansible/playbook.yml
fi

# Post-installation steps
if [ -n "$CUSTOM_ENV_VARS" ]; then
  echo -e "\n$CUSTOM_ENV_VARS" >> /root/.bashrc.env
fi
git config --global user.name "$GIT_USER"
git config --global user.email $GIT_EMAIL
git config --global user.signingkey $GIT_SIGNINGKEY
