FROM opensuse/tumbleweed@sha256:2750b5eff33c6a161973f2552050b5687ba3d9ad73f5eb0e525202c588760fb9
WORKDIR /root/workspace
RUN zypper ref && zypper in -y tmux k9s kubernetes-client kubelogin neovim ripgrep git gcc openssh nodejs22 npm22 docker docker-compose jq unzip python313 python313-pip python313-uv lldb wget fd iputils stow awk hurl tidy lazygit zoxide fzf
RUN rm /usr/lib64/python3.13/EXTERNALLY-MANAGED
RUN pip install -U neovim
RUN npm install -g neovim prettier @modelcontextprotocol/server-filesystem mcp-server-commands
RUN mkdir -p /root/.config/nvim /root/.config/mcphub /root/.gnup /root/scripts
COPY files/servers.json /root/.config/mcphub/
COPY files/scripts/ /root/scripts/
COPY files/*.sh /
RUN chmod +x /*.sh /root/scripts/*
RUN /rustup-install.sh -y
RUN /osh-install.sh --unattended
RUN git clone https://github.com/SteveBlum/dotfiles.git /root/.dotfiles
RUN rm /root/.bashrc /root/.bash_profile /root/.profile
RUN stow -d /root/.dotfiles -t ~ bash nvim oh-my-bash tmux tpm gnupg git
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    ~/.tmux/plugins/tpm/bin/install_plugins
#RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
ENTRYPOINT ["/start.sh"]
