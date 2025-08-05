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
    && groupadd -g 2375 docker \
    && usermod -l ede -d /ede -m -u 1000 -c "ede" -g staff -aG docker ubuntu \
    && groupdel ubuntu \
    && mkdir -p -m 6755 /nix /ede /state \
    && chown ede:staff /nix /ede /state \
    && echo "ede ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ede \
    && chmod 0440 /etc/sudoers.d/ede 
# && mv /usr/bin/env /usr/bin/env_

USER ede
WORKDIR /ede

ENV USER=ede \
    HOME=/ede \
    NIX_COLORS=1 \
    NIX_IGNORE_SYMLINK_STORE=1 \
    NIX_LOG_LEVEL=warn \
    NIXPKGS_ALLOW_UNFREE=1 \
    NIXPKGS_URL=github:NixOS/nixpkgs/nixos-unstable \
    XDG_STATE_HOME=/state 

RUN curl -L https://nixos.org/nix/install | sh -s -- \
    --no-daemon \
    --no-modify-profile \
    --yes \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc \
    && rm -rf /ede/.nix-defexpr/channels_root

COPY --chown=ede:staff fs/ede /ede
COPY --chown=root:root fs/etc /etc
COPY --chown=ede:staff fs/flakes /flakes
# COPY --chown=root:root fs/usr /usr
CMD [ "sleep", "infinity" ]
