FROM public.ecr.aws/ubuntu/ubuntu:noble AS upgraded

# Sourced from:
# https://github.com/devcontainers/images/blob/main/src/universal/.devcontainer/Dockerfile

RUN if id "ubuntu" &>/dev/null; then \
    echo "Deleting user 'ubuntu' for noble" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for noble"; \  
    else \
    echo "User 'ubuntu' does not exist for noble"; \ 
    fi

COPY first-run-notice.txt /tmp/scripts/

ENV LANG="C.UTF-8"

#Merging the mutiple layers to reduce the size of the image slightly
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Restore man command
    && yes | unminimize 2>&1 \ 
    # Install basic build tools
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    make \
    unzip \
    # The tools in this package are used when installing packages for Python
    build-essential \
    swig3.0 \
    # Required for Microsoft SQL Server
    unixodbc-dev \
    # Required for PostgreSQL
    libpq-dev \
    # Required for mysqlclient
    default-libmysqlclient-dev \
    # Required for ts
    moreutils \
    rsync \
    zip \
    libgdiplus \
    jq \
    # By default pip is not available in the buildpacks image
    python3-pip \
    #.NET Core related pre-requisites
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libncurses6 \
    liblttng-ust1 \
    libssl-dev \
    libstdc++6 \
    zlib1g \
    libuuid1 \
    libunwind8 \
    sqlite3 \
    libsqlite3-dev \
    software-properties-common \
    tk-dev \
    uuid-dev \
    curl \
    gettext \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/* \
    # This is the folder containing 'links' to benv and build script generator
    && apt-get update \
    && apt-get upgrade -y \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/* \
    # Verify expected build and debug tools are present
    && apt-get update \
    && apt-get -y install build-essential cmake cppcheck valgrind clang lldb llvm gdb python3-dev \
    # Install tools and shells not in common script
    && apt-get install -yq vim vim-doc xtail software-properties-common libsecret-1-dev \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y \
    # Move first run notice to right spot
    && mkdir -p "/usr/local/etc/vscode-dev-containers/" \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/ \
    # Install and setup fish
    && apt-get install -yq fish \
    && FISH_PROMPT="function fish_prompt\n    set_color green\n    echo -n (whoami)\n    set_color normal\n    echo -n \":\"\n    set_color blue\n    echo -n (pwd)\n    set_color normal\n    echo -n \"> \"\nend\n" \
    && printf "$FISH_PROMPT" >> /etc/fish/functions/fish_prompt.fish \
    && printf "if type code-insiders > /dev/null 2>&1; and not type code > /dev/null 2>&1\n  alias code=code-insiders\nend" >> /etc/fish/conf.d/code_alias.fish \   
    # Remove scripts now that we're done with them
    && apt-get clean -y && rm -rf /tmp/scripts

# Install libssl1.1 for oryx compatibility based on architecture
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then \
    curl -fsSL -o libssl1.1_1.1.0g-2ubuntu4_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    rm libssl1.1_1.1.0g-2ubuntu4_amd64.deb; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
    curl -fsSL -o libssl1.1_1.1.1f-1ubuntu2_arm64.deb http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_arm64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_arm64.deb && \
    rm libssl1.1_1.1.1f-1ubuntu2_arm64.deb; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1; \
    fi

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/bin/bash \
    DOCKER_BUILDKIT=1

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

CMD [ "sleep", "infinity" ]

# [Optional] Install debugger for development of Codespaces - Not in resulting image by default
ARG DeveloperBuild
RUN if [ -z $DeveloperBuild ]; then \
    echo "not including debugger" ; \
    else \
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
    fi

# Custom Dev tooling
FROM upgraded AS nix

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl sudo xz-utils gnupg ca-certificates procps direnv \
    git git-lfs ssh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -U --uid 1000 -s /bin/bash --create-home dev \
    && usermod -aG sudo dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev
ENV USER=dev HOME=/home/dev SHELL=/bin/bash
RUN curl -L https://nixos.org/nix/install | bash -s -- --no-daemon

USER root
COPY etc/nix /etc/nix
RUN . "$HOME/.nix-profile/etc/profile.d/nix.sh" && \
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
    nix-channel --update && \
    nix-collect-garbage -d

COPY home /home
COPY etc /etc
COPY usr /usr
RUN chown -R dev:dev /home/dev

USER dev
ENV PATH="/home/dev/.nix-profile/bin:$PATH"
ENV NIX_PATH="/home/dev/.nix-defexpr/channels"

RUN . "$HOME/.nix-profile/etc/profile.d/nix.sh" && \
    nix-env -f /home/default.nix -i

USER dev
WORKDIR /home/dev
RUN direnv allow
SHELL ["/bin/bash", "-l", "-c"]

# Final images
FROM nix AS linuxbrew

USER dev
RUN --mount=type=cache,target=/tmp/homebrew-cache,uid=1000,gid=1000 \
    HOMEBREW_CACHE=/tmp/homebrew-cache \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

USER root  
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Final images
FROM linuxbrew AS tooling

# USER dev
# RUN --mount=type=cache,target=/tmp/homebrew-cache,uid=1000,gid=1000 \
#     --mount=type=cache,target=/tmp/homebrew-downloads,uid=1000,gid=1000 \
#     HOMEBREW_CACHE=/tmp/homebrew-cache \
#     HOMEBREW_TEMP=/tmp/homebrew-downloads \
#     brew install htop jq && \
#     brew cleanup --prune=all

# Copy and run installation script
RUN --mount=type=cache,target=/tmp/tool-cache \
    cd /home/dev && eval "$(direnv export bash)" && \
    sudo -u root /home/packages.sh && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

FROM tooling AS final

USER dev
ENV PATH="/home/dev/.nix-profile/bin:$PATH"
ENV NIX_PATH="/home/dev/.nix-defexpr/channels"
SHELL ["/bin/bash", "-l", "-c"]

RUN echo "Testing Nix tools:" && \
    cd /home/dev && eval "$(direnv export bash)" && \
    kubectl version --client && \
    echo "Testing Homebrew:" && \
    brew --version && \
    echo "Testing optimized tools:" && \
    k9s version && \
    p6m --version && \
    archetect --version && \
    echo "Smoke test successful: All tools installed correctly."

CMD [ "sleep", "infinity" ]
