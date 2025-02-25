FROM opensuse/tumbleweed@sha256:929905007a13ffbb406118e35b771677c198190a716126038a5a820b7d96d22f
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
