FROM opensuse/leap:15.6
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s neovim ripgrep git gcc openssh nodejs20 npm20 docker jq
RUN mkdir -p /root/.config/nvim /root/.gnup
COPY files/start.sh /
RUN chmod +x /start.sh
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
COPY files/.bashrc /root/
RUN nvim --headless "+Lazy! sync" +qa
ENTRYPOINT ["/start.sh"]
