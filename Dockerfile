FROM opensuse/tumbleweed@sha256:70f84c745f848ce694b1a803bb840cebd9dbff1eacc7f96f611dc40123e9cddb
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python3 python314
RUN mkdir -p /root/.config/nvim /root/.gnup
COPY files/start.sh /
RUN chmod +x /start.sh
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
COPY files/.bashrc /root/
RUN nvim --headless "+Lazy! sync" +qa
ENTRYPOINT ["/start.sh"]
