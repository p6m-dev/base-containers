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

USER dev
WORKDIR /home/dev

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV USER=dev
ENV DIRENV_ALLOW_NOALLOW=1
ENV DIRENV_CONFIG=/etc/direnv

SHELL ["/bin/bash", "-c"]
RUN rm /home/dev/.nix-defexpr/channels_root && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
    echo ". /home/dev/.nix-profile/etc/profile.d/nix.sh" >> ~/.zshrc && \
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && \
    mkdir -p ~/.config/fish && \
    echo 'if status --is-interactive; and command -v direnv >/dev/null; direnv hook fish | source; end' >> ~/.config/fish/config.fish

RUN . /home/dev/.nix-profile/etc/profile.d/nix.sh && nix --version

# Smoke test: validate default.nix
RUN . /home/dev/.nix-profile/etc/profile.d/nix.sh && \
    nix-instantiate --parse /etc/nix/default.nix > /dev/null && \
    echo "✓ /etc/nix/default.nix syntax validated"

# Run all tests in a single layer and cleanup
COPY --chmod=755 tests/test_script.sh /tmp/test_script.sh
COPY --chmod=755 tests/test_args.sh /tmp/test_args.sh
COPY --chmod=755 tests/test_default_env.sh /tmp/test_default_env.sh
COPY --chmod=755 tests/test_envrc_nodejs.sh /tmp/test_envrc_nodejs.sh
COPY --chmod=755 tests/test_safe_file_exists.sh /tmp/test_safe_file_exists.sh
COPY tests/parent-project /tmp/parent-project
RUN set -e && \
    # Test shebang script functionality
    /tmp/test_script.sh && \
    echo "✓ Shebang script execution works" && \
    \
    # Test shebang script with arguments
    /tmp/test_args.sh hello world "test with spaces" && \
    echo "✓ Shebang script with arguments works" && \
    \
    # Test default environment (no .envrc)
    cd /tmp && /tmp/test_default_env.sh && \
    echo "✓ Default environment test works" && \
    \
    # Test .envrc environment with Node.js project (parent directory with subdirectory)
    cd /tmp/parent-project && \
    direnv allow && \
    /tmp/test_envrc_nodejs.sh && \
    echo "✓ .envrc Node.js environment test works" && \
    \
    # Test safe file exists functionality
    /tmp/test_safe_file_exists.sh && \
    echo "✓ Safe file exists test works" && \
    \
    # Cleanup test files
    sudo rm -rf /tmp/test_*.sh /tmp/parent-project && \
    \
    # Cleanup Nix store to reduce image size
    . /home/dev/.nix-profile/etc/profile.d/nix.sh && \
    nix-collect-garbage -d && \
    sudo rm -rf /nix/var/nix/gcroots/auto/* && \
    nix-store --optimize

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "sleep", "infinity" ]
