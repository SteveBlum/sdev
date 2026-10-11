#!/bin/bash
/runtime-setup.sh
/usr/bin/supervisord -c /etc/supervisord.conf &
tmux -u
