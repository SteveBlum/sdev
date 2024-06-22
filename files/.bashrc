export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="/root/.gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye > /dev/null
