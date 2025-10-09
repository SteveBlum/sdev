FROM opensuse/tumbleweed@sha256:693be14f7309f8ed8d0e19bd5beed26abbc9013e1b8e2054a586b0ede809bc2e
LABEL maintainer="Steve Blum"
LABEL description="My personal development envionment"

WORKDIR /root/workspace

# Install system packages
RUN zypper ref && zypper in -y \
    tmux \
    k9s \
    kubernetes-client \
    kubelogin \
    neovim \
    ripgrep \
    git \
    gcc \
    openssh \
    nodejs22 \
    npm22 \
    docker \
    docker-compose \
    jq \
    unzip \
    python313 \
    python313-pip \
    python313-uv \
    lldb \
    wget \
    fd \
    iputils \
    stow \
    awk \
    hurl \
    tidy \
    lazygit \
    zoxide \
    fzf \
    && zypper clean -a

# Setup Python and Node.js
RUN rm /usr/lib64/python3.13/EXTERNALLY-MANAGED && \
    pip install -U neovim && \
    npm install -g neovim prettier @modelcontextprotocol/server-filesystem mcp-server-commands
RUN mkdir -p /root/.config/nvim /root/.config/mcphub /root/.gnup /root/scripts
COPY files/servers.json /root/.config/mcphub/
COPY files/scripts/ /root/scripts/

# Copy and prepare scripts
COPY files/*.sh /
RUN chmod +x /*.sh /root/scripts/*

# Install additional tools and setup environment
RUN /rustup-install.sh -y && \
    /osh-install.sh --unattended && \
    git clone https://github.com/SteveBlum/dotfiles.git /root/.dotfiles && \
    rm /root/.bashrc /root/.bash_profile /root/.profile && \
    stow -d /root/.dotfiles -t ~ bash nvim oh-my-bash tmux tpm gnupg git k9s && \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    ~/.tmux/plugins/tpm/bin/install_plugins && \
    nvim --headless -c 'luafile /root/.config/nvim/install.lua' -c 'qall'

# Set environment variables
ENV LANG=en_US.UTF-8
ENV EDITOR=nvim

ENTRYPOINT ["/start.sh"]
