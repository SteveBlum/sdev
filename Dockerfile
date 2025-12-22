FROM opensuse/tumbleweed@sha256:81a606bbb1fa44a010c8aca7f5e5beb2123aaafbc67243254059e6f599bb0417
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
