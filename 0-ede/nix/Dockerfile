FROM public.ecr.aws/ubuntu/ubuntu:noble

RUN apt-get update && apt-get install -y \
    acl \
    bash \
    ca-certificates \
    curl \
    git \
    gnupg \
    man-db \
    sudo \
    xz-utils \
    zsh \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && usermod -l ede -d /ede -m -u 1000 -c "ede" ubuntu \
    && groupmod -n ede -g 1000 ubuntu \
    && usermod -aG staff ede \
    && chsh -s /usr/bin/nix-shell ede \ 
    && mkdir -p -m 2755 /nix /ede /state \
    && chown ede:staff /nix /ede /state \
    && setfacl -d -m u::rwx,g::rwx,o::r-- /ede /state \
    && echo "ede ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ede \
    && chmod 0440 /etc/sudoers.d/ede \
    && mv /usr/bin/env /usr/bin/env_

USER ede
WORKDIR /ede
SHELL ["/bin/bash", "-c"]

ENV USER=ede \
    HOME=/ede \
    NIX_IGNORE_SYMLINK_STORE=1 \
    XDG_STATE_HOME=/state \
    NIX_LOG_LEVEL=warn

RUN curl -L https://nixos.org/nix/install \
    | sh -s -- \
    --no-daemon \
    --no-modify-profile \
    --yes \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc \
    && rm -rf /ede/.nix-defexpr/channels_root

COPY rootfs /

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "sleep", "infinity" ]
