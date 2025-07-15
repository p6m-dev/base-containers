FROM public.ecr.aws/ubuntu/ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    gnupg \
    ca-certificates \
    sudo \
    git \
    bash \
    zsh \
    fish \
    direnv \
    man-db \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -l dev -d /home/dev -m -u 1000 -c "dev" ubuntu && \
    groupmod -n dev -g 1000 ubuntu && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mv /usr/bin/env /usr/bin/_env
COPY etc /etc
COPY usr /usr

USER dev
WORKDIR /home/dev

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV USER=dev
ENV DIRENV_CONFIG=/etc/direnv
ENV DIRENV_LOG_FORMAT=""
ENV NIX_LOG_LEVEL=warn

SHELL ["/bin/bash", "-c"]
RUN rm /home/dev/.nix-defexpr/channels_root && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc && \
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

CMD [ "sleep", "infinity" ]
