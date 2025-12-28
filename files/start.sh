#!/bin/bash
git config --global user.name "$GIT_USER"
git config --global user.email $GIT_EMAIL
git config --global user.signingkey $GIT_SIGNINGKEY
/runtime-setup.sh
/usr/bin/supervisord -c /etc/supervisord.conf &
tmux new-session -d -s my_session -n 'goose' "tail -F /var/log/goose.out" \; new-window -t my_session:1 && tmux attach -t my_session
