FROM opensuse/tumbleweed@sha256:b8ba97077655f3fa7b273f75aee90d5fef7723c30ef0f6402f1c13e447ac3a53
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s kubernetes-client neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python3 python3-pip lldb
RUN mkdir -p /root/.config/nvim /root/.gnup
COPY files/.bashrc /root/
COPY files/start.sh /
COPY files/rustup-install.sh /
RUN chmod +x /start.sh /rustup-install.sh
RUN /rustup-install.sh -y
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
#RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
ENTRYPOINT ["/start.sh"]
