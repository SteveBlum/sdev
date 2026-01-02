FROM opensuse/tumbleweed@sha256:7558e0849f6d7a65a579675b2433d59e2c4fdffc13d339ff88757651c791bd6c
LABEL maintainer="Steve Blum"
LABEL description="My personal development envionment"

WORKDIR /root/workspace

# Set environment variables
ENV LANG=en_US.UTF-8
ENV EDITOR=nvim
ENV PIPX_HOME=/root/.pipx

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
    python313-pipx \
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
    yq \
    bzip2 \
    libxcb1 \
    supervisor \
    && zypper clean -a

# Setup Python and Node.js
RUN mkdir -p /root/.config/nvim /root/.config/mcphub /root/.gnup /root/scripts /root/.pipx /root/.npm  && \
    pipx ensurepath && \
    npm config set prefix /root/.npm && \
    echo "export PATH=\"/root/.npm/bin:/root/.local/bin:$PATH\"" > /root/.bashrc.env && \
    echo "export GOOSE_DISABLE_KEYRING=\"true\"" >> /root/.bashrc.env && \
    chmod +x /root/.bashrc.env

COPY files/scripts/ /root/scripts/

# Copy and prepare scripts
COPY files/*.sh /
RUN chmod +x /*.sh /root/scripts/*
COPY files/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log /var/run && chmod 755 /var/log /var/run

# Install additional tools and setup environment
RUN /rustup-install.sh -y && \
    /osh-install.sh --unattended && \
    git clone https://github.com/SteveBlum/dotfiles.git /root/.dotfiles && \
    rm /root/.bashrc /root/.bash_profile /root/.profile && \
    stow -d /root/.dotfiles -t ~ bash nvim oh-my-bash tmux tpm gnupg git k9s mcp-server crush goose && \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    mkdir /run/tmux && \
    chmod 1777 /run/tmux && \
    ~/.tmux/plugins/tpm/bin/install_plugins

# Prepare MCP Setup
RUN mkdir -p /mcpworkspace && \
    ln -s /root/workspace /mcpworkspace/workspace && \
    ln -s /root/shared /mcpworkspace/shared

ENTRYPOINT ["/start.sh"]
