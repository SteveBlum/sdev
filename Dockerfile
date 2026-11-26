FROM opensuse/tumbleweed@sha256:572838c03f4ec87cb78b59bf05657f62794cb9bb0c876306ecc9387bdc31e5f8
LABEL maintainer="Steve Blum"
LABEL description="My personal development envionment"

WORKDIR /root/workspace

# Set environment variables
ENV LANG=en_US.UTF-8
ENV EDITOR=nvim
ENV PIPX_HOME=/root/.pipx
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Install only what's needed to run the ansible setup
RUN zypper ref && zypper in -y \
    python313 \
    ansible \
    && zypper clean -a

COPY files/ansible/ /root/ansible/

# Copy and prepare scripts
COPY files/*.sh /
RUN chmod +x /*.sh
COPY files/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log /var/run && chmod 755 /var/log /var/run

RUN ansible-playbook -i /root/ansible/inventory.ini /root/ansible/build.yml

ENTRYPOINT ["/start.sh"]
