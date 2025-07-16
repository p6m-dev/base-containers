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
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && usermod -l ede -d /ede -m -u 1000 -c "ede" ubuntu \
    && groupmod -n ede -g 1000 ubuntu \
    && usermod -aG staff ede \ 
    && mkdir -p -m 2755 /nix /ede /state \
    && chown ede:staff /nix /ede /state \
    && setfacl -d -m u::rwx,g::rwx,o::r-- /ede /state \
    && echo "ede ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ede \
    && chmod 0440 /etc/sudoers.d/ede

USER ede
WORKDIR /ede
SHELL ["/bin/bash", "-c"]

ENV USER=ede \
    HOME=/ede \
    NIX_IGNORE_SYMLINK_STORE=1 \
    XDG_STATE_HOME=/state \
    NIX_LOG_LEVEL=warn \
    DIRENV_CONFIG=/etc/direnv \
    DIRENV_LOG_FORMAT=""

RUN curl -L https://nixos.org/nix/install \
    | sh -s -- \
    --no-daemon \
    --no-modify-profile \
    --yes \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc \
    && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
    && echo ". /ede/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc \
    && echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc \
    && rm -rf /ede/.nix-defexpr/channels_root

COPY etc /etc
COPY ede /ede

# # RUN mv /usr/bin/env /usr/bin/_env
# COPY etc /etc
# # COPY usr /usr

# USER dev
# WORKDIR /ede
# ENV NIX_IGNORE_SYMLINK_STORE=1
# ENV NIX_STORE_DIR=/ede/nix/store
# ENV DIRENV_CONFIG=/etc/direnv
# ENV DIRENV_LOG_FORMAT=""

# RUN curl -L https://nixos.org/nix/install \
#     | sh -s -- \
#     --no-daemon \
#     --no-modify-profile

# ENV USER=dev
# ENV DIRENV_CONFIG=/etc/direnv
# ENV DIRENV_LOG_FORMAT=""
# ENV NIX_LOG_LEVEL=warn

# SHELL ["/bin/bash", "-c"]
# RUN rm /home/dev/.nix-defexpr/channels_root && \
#     echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc && \
#     echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
#     echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc && \
#     echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# CMD [ "sleep", "infinity" ]
