FROM public.ecr.aws/ubuntu/ubuntu:noble

RUN apt-get update && apt-get install -y \
    acl \
    bash \
    ca-certificates \
    curl \
    direnv \
    git \
    gnupg \
    man-db \
    sudo \
    xz-utils \
    zsh \
    jq \
    moreutils \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && groupadd -g 2375 docker \
    && usermod -l ede -d /ede -m -u 1000 -c "ede" -g staff -aG docker ubuntu \
    && groupdel ubuntu \
    && mkdir -p -m 6755 /nix /ede /build /cache /config /data /state \
    && chown ede:staff /nix /ede /build /cache /config /data /state \
    && echo "ede ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ede \
    && chmod 0440 /etc/sudoers.d/ede 
# && mv /usr/bin/env /usr/bin/env_

USER ede
WORKDIR /ede

COPY --chown=ede:staff fs/ede /ede
COPY --chown=root:root fs/etc /etc

RUN curl -L https://nixos.org/nix/install | sh -s -- \
    --no-daemon \
    --no-modify-profile \
    --yes \
    # && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc \
    # && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc \
    && rm -rf /ede/.nix-defexpr/channels_root \
    && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
    && echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc \
    && direnv allow /ede

ENV USER=ede \
    HOME=/ede \
    DIRENV_CONFIG="/ede/.config/direnv" \
    DIRENV_LOG_FORMAT="" \
    DIRENV_WARN_TIMEOUT=5m \
    NIX_COLORS=1 \
    NIX_LOG_LEVEL=warn \
    NIX_PROFILES="/nix/var/nix/profiles/default:/ede/.nix-profile" \
    NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" \
    NIXPKGS_ALLOW_UNFREE=1 \
    NIXPKGS_URL=github:NixOS/nixpkgs/nixos-unstable \
    PATH="/ede/.nix-profile/bin:$PATH" \
    XDG_DATA_DIRS="/usr/local/share:/usr/share:/ede/.nix-profile/share:/nix/var/nix/profiles/default/share" \
    XDG_CACHE_HOME=/cache \
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data \ 
    XDG_STATE_HOME=/state

# COPY --chown=ede:staff fs/flakes /flakes
# COPY --chown=root:root fs/usr /usr

ENTRYPOINT [ "nix", "shell", "--impure", "--command" ]

# ### TESTS ###
# ### Only activated with --target on docker build command ###
# FROM base AS test-detections
# COPY --chown=ede:staff tests/test-detections/fs/ede /ede
# WORKDIR /ede/orgs/some-org
# RUN direnv exec . rustc --version

# ### FINAL IMAGE ###
# FROM base
# CMD [ "sleep", "infinity" ]