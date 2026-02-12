FROM opensuse/tumbleweed@sha256:d06ca06b42c9bb99538c9c6ccf786e3ca9eaefd6f87671f34248649ce527b49e
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
    supervisor \
    && zypper clean -a

# Setup Python and Node.js
RUN mkdir -p /root/.config/nvim /root/.config/mcphub /root/.gnup /root/scripts /root/.pipx /root/.npm  && \
    pipx ensurepath && \
    npm config set prefix /root/.npm && \
    echo "export PATH=\"/root/.npm/bin:/root/.local/bin:$PATH\"" > /root/.bashrc.env && \
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
    stow -d /root/.dotfiles -t ~ bash nvim oh-my-bash tmux tpm gnupg git k9s mcp-server opencode && \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    mkdir /run/tmux && \
    chmod 1777 /run/tmux && \
    ~/.tmux/plugins/tpm/bin/install_plugins

# Prepare MCP Setup
RUN mkdir -p /mcpworkspace && \
    ln -s /root/workspace /mcpworkspace/workspace && \
    ln -s /root/shared /mcpworkspace/shared

ENTRYPOINT ["/start.sh"]
