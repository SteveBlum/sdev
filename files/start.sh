#!/bin/bash
/runtime-setup.sh
/usr/bin/supervisord -c /etc/supervisord.conf &
tmux -u new-session -t 0 -s primary
