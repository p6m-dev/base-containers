# Global ARG
ARG REGISTRY_PREFIX=ybor

# TODO
#    github.copilot \
#    github.copilot-chat \
#    ms-dotnettools.csdevkit \
#    ms-dotnettools.csharp \
#    ms-python.vscode-pylance \
#    ms-vscode-remote.remote-containers \
#    ms-vsliveshare.vsliveshare \
#    openai.chatgpt \
#    rhai-script.vscode-rhai \
#    rvest.vscode-prettier-eslint \
#    visualstudioexptteam.intellicode-api-usage-examples \
#    visualstudioexptteam.vscodeintellicode \

# TODO: Multi-stage build for VSIX creation - continue later
# # Build stage for downloading VS Code and creating VSIX files
# FROM ubuntu:22.04 AS vscode-builder
# 
# ARG DEBIAN_FRONTEND=noninteractive
# RUN apt-get update && apt-get install -y \
#     curl \
#     wget \
#     tar \
#     unzip \
#     zip \
#     xvfb \
#     libasound2 \
#     libgtk-3-0 \
#     libxss1 \
#     libnss3 \
#     libgconf-2-4 \
#     libatspi2.0-0 \
#     libdrm2 \
#     libxcomposite1 \
#     libxdamage1 \
#     libxrandr2 \
#     libgbm1 \
#     && rm -rf /var/lib/apt/lists/*
# 
# # Download and install VS Code
# ARG VSCODE_VERSION=1.102.3
# RUN ARCH=$(uname -m) && \
#     case "$ARCH" in \
#     x86_64) ARCH_SUFFIX="x64" ;; \
#     aarch64) ARCH_SUFFIX="arm64" ;; \
#     *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
#     esac && \
#     wget -O vscode.tar.gz "https://update.code.visualstudio.com/latest/linux-${ARCH_SUFFIX}/stable" && \
#     tar -xzf vscode.tar.gz && \
#     mv VSCode-linux-* /vscode && \
#     rm vscode.tar.gz
# 
# ENV PATH="/vscode/bin:$PATH"
# 
# # Create user and install extensions
# RUN useradd -m -s /bin/bash vscode && \
#     mkdir -p /vsix && \
#     chown -R vscode:vscode /vsix
# 
# USER vscode
# WORKDIR /home/vscode
# 
# # Install the commented-out extensions and create VSIX files
# RUN FAILED_EXTS="\
#     github.copilot \
#     github.copilot-chat \
#     ms-dotnettools.csdevkit \
#     ms-dotnettools.csharp \
#     ms-python.vscode-pylance \
#     ms-vscode-remote.remote-containers \
#     ms-vsliveshare.vsliveshare \
#     openai.chatgpt \
#     rhai-script.vscode-rhai \
#     rvest.vscode-prettier-eslint \
#     visualstudioexptteam.intellicode-api-usage-examples \
#     visualstudioexptteam.vscodeintellicode" && \
#     for EXT in $FAILED_EXTS; do \
#     echo "Installing and packaging extension: $EXT" && \
#     xvfb-run -a code --no-sandbox --user-data-dir=/tmp/vscode-data --install-extension "$EXT" --force && \
#     VSIX_PATH=$(find ~/.vscode/extensions -name "*${EXT}*" -type d | head -1) && \
#     if [ -n "$VSIX_PATH" ] && [ -d "$VSIX_PATH" ]; then \
#     EXT_NAME=$(basename "$VSIX_PATH") && \
#     cd "$VSIX_PATH" && \
#     zip -r "/vsix/${EXT_NAME}.vsix" . && \
#     echo "Created VSIX: /vsix/${EXT_NAME}.vsix"; \
#     else \
#     echo "Failed to find extension directory for $EXT"; \
#     fi; \
#     done
# 
# USER root

# Main stage
FROM $REGISTRY_PREFIX/ede:nix

# TODO: Copy VSIX files from build stage when multi-stage is enabled
# COPY --from=vscode-builder /vsix /vsix

ARG VERSION=v1.102.3
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
    x86_64) ARCH_SUFFIX="x64" ;; \
    aarch64) ARCH_SUFFIX="arm64" ;; \
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    URL="https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-${VERSION}/openvscode-server-${VERSION}-linux-${ARCH_SUFFIX}.tar.gz" && \
    echo "Downloading: $URL" && \
    sudo mkdir -p /vsc && \
    curl -fsSL "$URL" | sudo tar -xz --strip-components=1 -C /vsc

ENV PATH="/vsc/bin:$PATH"

RUN EXTS="\
    anthropic.claude-code \
    bradlc.vscode-tailwindcss \
    dbaeumer.vscode-eslint \
    docker.docker \
    dsznajder.es7-react-js-snippets \
    eamodio.gitlens \
    esbenp.prettier-vscode \
    fill-labs.dependi \
    firsttris.vscode-jest-runner \
    formulahendry.auto-close-tag \
    formulahendry.auto-rename-tag \
    github.vscode-github-actions \
    golang.go \
    gruntfuggly.todo-tree \
    hashicorp.terraform \
    mikestead.dotenv \
    ms-azuretools.vscode-containers \
    ms-azuretools.vscode-docker \
    ms-dotnettools.vscode-dotnet-runtime \
    ms-playwright.playwright \
    ms-python.debugpy \
    ms-python.python \
    nrwl.angular-console \
    redhat.java \
    redhat.vscode-xml \
    redhat.vscode-yaml \
    rust-lang.rust-analyzer \
    streetsidesoftware.code-spell-checker \
    stylelint.vscode-stylelint \
    tamasfe.even-better-toml \
    vscjava.vscode-gradle \
    vscjava.vscode-java-debug \
    vscjava.vscode-java-dependency \
    vscjava.vscode-java-pack \
    vscjava.vscode-java-test \
    vscjava.vscode-maven" && \
    for EXT in $EXTS; do \
    echo "Installing extension: $EXT" && \
    openvscode-server --install-extension "$EXT"; \
    done && \
    echo "All extensions installed successfully." && \
    # TODO: Install VSIX extensions when multi-stage is enabled
    # echo "Installing VSIX extensions..." && \
    # for VSIX in /vsix/*.vsix; do \
    # if [ -f "$VSIX" ]; then \
    # echo "Installing VSIX: $VSIX" && \
    # openvscode-server --install-extension "$VSIX" --force; \
    # fi; \
    # done && \
    # echo "All VSIX extensions installed." && \
    rm -rf ~/.vscode-server/extensionsCache && \
    rm -rf ~/.vscode-server/logs && \
    rm -rf /tmp/*
    # rm -rf /vsix

CMD [ "openvscode-server" ]