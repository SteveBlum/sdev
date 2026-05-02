FROM opensuse/tumbleweed@sha256:548095e08bfd4a2e1959790c36e7be2d1ec50a1c43bf1a82fdc2484c22a75427
LABEL maintainer="Steve Blum"
LABEL description="My personal development envionment"

WORKDIR /root/workspace

# Set environment variables
ENV LANG=en_US.UTF-8
ENV EDITOR=nvim
ENV PIPX_HOME=/root/.pipx

# for an up-to-date neovim version
RUN zypper ar -f -p 90 https://download.opensuse.org/repositories/editors/openSUSE_Tumbleweed/ editors && \
    zypper --gpg-auto-import-keys ref

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
    nodejs24 \
    npm24 \
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
    azure-cli \
    helm \
    && zypper clean -a

ARG TERRAFORM_VERSION=1.15.1
ARG TERRAFORM_SHA256=0921fee8c8435253ca49390a02109e906042e611a4e17f69e922261f5176c74f
ARG TERRAFORM_ARCH=linux_amd64

RUN wget -qO /tmp/terraform.zip \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_ARCH}.zip" \
  && echo "${TERRAFORM_SHA256}  /tmp/terraform.zip" | sha256sum -c - \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && chmod +x /usr/local/bin/terraform \
  && rm -f /tmp/terraform.zip

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
