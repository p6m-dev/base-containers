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
ENV DIRENV_CONFIG=/etc/direnv/direnv.toml
ENV NIX_PATH=/home/dev/.nix-defexpr/channels
ENV PATH=/home/dev/.nix-profile/bin:/home/dev/.nix-profile/sbin:/home/dev/.nix-profile:/home/dev/.nix-profile/libexec:/home/dev/.nix-profile/libexec/nix:$PATH

SHELL ["/bin/bash", "-c"]
RUN direnv allow && \
    rm /home/dev/.nix-defexpr/channels_root && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc && \
    echo 'eval "$(direnv export bash)"' >> ~/.profile

RUN . /home/dev/.nix-profile/etc/profile.d/nix.sh && nix --version
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD [ "sleep", "infinity" ]
