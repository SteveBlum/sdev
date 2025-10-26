#!/bin/bash
git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global user.signingkey $GIT_SIGNINGKEY
/runtime-setup.sh
tmux -u
