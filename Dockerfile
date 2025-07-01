FROM opensuse/tumbleweed@sha256:81584e670e20f7f4ba0ec12589917e98324faa1b748a3af8ae5dba410092d806
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
