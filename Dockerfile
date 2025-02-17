FROM opensuse/tumbleweed@sha256:7da099fa89973d8f9573607de7180615b9866b5997f6de01cbcfebe8e48bc9a5
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
