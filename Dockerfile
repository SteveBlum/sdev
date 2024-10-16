FROM opensuse/leap@sha256:d3a517b66067d9f150dbd57d7ad28e0806025ad6f3a3e8c71b09cc7230b833a6
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s neovim ripgrep git gcc openssh nodejs20 npm20 docker jq unzip python3 python312
RUN mkdir -p /root/.config/nvim /root/.gnup
COPY files/start.sh /
RUN chmod +x /start.sh
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
COPY files/.bashrc /root/
RUN nvim --headless "+Lazy! sync" +qa
ENTRYPOINT ["/start.sh"]
