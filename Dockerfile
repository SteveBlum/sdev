FROM opensuse/tumbleweed@sha256:70de5a83a15140d61d3b22f304e78c69f596ca9849a0e481a739101517d98767
WORKDIR /root/workspace
RUN zypper ref && zypper in -y tmux k9s kubernetes-client kubelogin neovim ripgrep git gcc openssh nodejs22 npm22 docker jq unzip python313 python313-pip lldb wget fd
RUN rm /usr/lib64/python3.13/EXTERNALLY-MANAGED
RUN pip install -U neovim
RUN npm install -g neovim prettier
RUN mkdir -p /root/.config/nvim /root/.gnup /root/scripts
COPY files/scripts/ /root/scripts/
COPY files/.bashrc /root/
COPY files/.tmux.conf /root/.tmux.conf
COPY files/start.sh /
COPY files/rustup-install.sh /
RUN chmod +x /start.sh /rustup-install.sh /root/scripts/*
RUN /rustup-install.sh -y
COPY files/nvim/ /root/.config/nvim/
COPY files/gpg-agent.conf /root/.gnupg/
COPY files/.gitconfig /root/
#RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'
ENTRYPOINT ["/start.sh"]
