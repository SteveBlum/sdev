FROM opensuse/tumbleweed@sha256:2fa4ba3b1e7c04faace7e19d75ba79f79b5bba92e30917f61e3b0401227d9438
WORKDIR /root/workspace
RUN zypper ref && zypper in -y k9s neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python3 python314 lldb
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
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall' \
ENTRYPOINT ["/start.sh"]
