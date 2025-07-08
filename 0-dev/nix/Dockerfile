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
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mv /usr/bin/env /usr/bin/_env
COPY etc /etc
COPY usr /usr
COPY .envrc /.envrc
COPY default.nix /default.nix

USER dev
WORKDIR /home/dev

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV USER=dev
ENV DIRENV_ALLOW_NOALLOW=1
ENV DIRENV_CONFIG=/etc/direnv

SHELL ["/bin/bash", "-c"]
RUN direnv allow && \
    rm /home/dev/.nix-defexpr/channels_root && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc && \
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && \
    mkdir -p ~/.config/fish && \
    echo 'if status --is-interactive; and command -v direnv >/dev/null; direnv hook fish | source; end' >> ~/.config/fish/config.fish

RUN . /home/dev/.nix-profile/etc/profile.d/nix.sh && nix --version

# Smoke test: validate default.nix syntax only
RUN . /home/dev/.nix-profile/etc/profile.d/nix.sh && \
    nix-instantiate --parse /default.nix > /dev/null && \
    echo "✓ default.nix syntax validated"

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD [ "sleep", "infinity" ]
