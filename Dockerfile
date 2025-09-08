FROM opensuse/tumbleweed@sha256:3b818e523754067b11d759b512e341e26fe6895358fbe16bb4e911646306c630
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
RUN stow -d /root/.dotfiles -t ~ bash nvim oh-my-bash tmux tpm gnupg git k9s
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    ~/.tmux/plugins/tpm/bin/install_plugins
#RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
ENTRYPOINT ["/start.sh"]
