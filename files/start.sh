#!/bin/bash
git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global user.signingkey $GIT_SIGNINGKEY
/runtime-setup.sh
tmux new-session -d -s my_session -n 'goose' 'goose web --host 0.0.0.0 --port 3010' -u \; new-window -t my_session:2 && tmux attach -t my_session
