FROM opensuse/tumbleweed@sha256:b014814cb769cb06cb019dd35b57f8a3ce862763a9f775e3cab53a62cd44458e
WORKDIR /root/workspace
RUN zypper ref && zypper in -y tmux k9s kubernetes-client kubelogin neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python313 python313-pip python313-uv lldb wget fd
RUN rm /usr/lib64/python3.13/EXTERNALLY-MANAGED
RUN pip install -U neovim
RUN npm install -g neovim prettier @modelcontextprotocol/server-filesystem mcp-server-commands
RUN mkdir -p /root/.config/nvim /root/.config/mcphub /root/.gnup /root/scripts
COPY files/scripts/ /root/scripts/
COPY files/.bashrc /root/
COPY files/.tmux.conf /root/.tmux.conf
COPY files/start.sh /
COPY files/rustup-install.sh /
COPY files/servers.json /root/.config/mcphub/
RUN chmod +x /start.sh /rustup-install.sh /root/scripts/*
RUN /rustup-install.sh -y
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
#RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
ENTRYPOINT ["/start.sh"]
