FROM opensuse/tumbleweed@sha256:a62372eabe0a60475dd4d28a16d940ec0a873a7953eb1a5fd5d588036d5e0088
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python3 python314
RUN mkdir -p /root/.config/nvim /root/.gnup
COPY files/start.sh /
RUN chmod +x /start.sh
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
COPY files/.bashrc /root/
RUN nvim --headless "+Lazy! sync" +qa \
    && nvim --headless "+Lazy! load mason.nvim +MasonInstall +sleep 45" +qa
ENTRYPOINT ["/start.sh"]
