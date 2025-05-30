ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/ubuntu:noble AS base

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

# Custom ybor tooling
FROM base

RUN apt-get update && apt-get install -y --no-install-recommends \
    direnv nix \
    && rm -rf /var/lib/apt/lists/*

# Set global direnv config and nix PATH
ENV DIRENV_CONFIG=/etc/direnv \
    PATH="/nix/var/nix/profiles/system/bin:/usr/bin:/bin:$PATH" \
    NIX_PATH="nixpkgs=channel:nixos-unstable"

COPY system.nix system.nix

RUN --mount=type=cache,target=/root/.cache/nix \
    nix-env -p /nix/var/nix/profiles/system -f system.nix -i \
    && echo "Nix packages installed to system profile"

# Install Homebrew with checksum verification (pinned to stable commit)
RUN HOMEBREW_COMMIT="4407e35affd529b11904d9757aade0efddfce4db" \
    && HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_COMMIT}/install.sh" \
    && EXPECTED_SHA="24a5e8ba70e6010c911bc92b960fb7eff27590d1afb460926e3c05d20d47c69f" \
    && curl -fsSL "$HOMEBREW_INSTALL_URL" -o install.sh \
    && echo "$EXPECTED_SHA install.sh" | sha256sum -c - \
    && NONINTERACTIVE=1 /bin/bash install.sh \
    && rm install.sh \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > /etc/profile.d/brew.sh

# Setup homebrew and install additional tools
RUN --mount=type=cache,target=/home/linuxbrew/.linuxbrew/var/homebrew/cache \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew tap archetect/tap \
    && brew install archetect

WORKDIR /

CMD [ "sleep", "infinity" ]