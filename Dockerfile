FROM opensuse/leap:42.3@sha256:271c921a1c84d65467d565e3f1c754b75aa01ceed1a7ac39de4816683c355fd2
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
