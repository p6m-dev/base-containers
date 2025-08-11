ARG REGISTRY_PREFIX=ybor
FROM $REGISTRY_PREFIX/ede:nix

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

# Find and install the the latest EDE VSCode release from https://github.com/ybor-studio/ede-vscode/releases
RUN LATEST_RELEASE=$(curl -s https://api.github.com/repos/ybor-studio/ede-vscode/releases/latest | jq -r .tag_name) && \
    echo "EDE-VScode Latest release: $LATEST_RELEASE" && \
    curl -L -o /tmp/ede-vscode.vsix "https://github.com/ybor-studio/ede-vscode/releases/download/$LATEST_RELEASE/ede-vscode-$LATEST_RELEASE.vsix" && \
    echo "Installing EDE-VScode extension..." && \
    openvscode-server --install-extension /tmp/ede-vscode.vsix --force && \
    echo "EDE-VScode extension installed successfully." && \
    rm /tmp/ede-vscode.vsix

RUN EXTS="\
    anthropic.claude-code \
    bradlc.vscode-tailwindcss \
    dbaeumer.vscode-eslint \
    docker.docker \
    esbenp.prettier-vscode \
    firsttris.vscode-jest-runner \
    formulahendry.auto-close-tag \
    formulahendry.auto-rename-tag \
    github.copilot \
    github.copilot-chat \
    github.vscode-github-actions \
    golang.go \
    mikestead.dotenv \
    ms-azuretools.vscode-containers \
    ms-azuretools.vscode-docker \
    ms-dotnettools.csdevkit \
    ms-dotnettools.csharp \
    ms-dotnettools.vscode-dotnet-runtime \
    ms-playwright.playwright \
    ms-python.debugpy \
    ms-python.python \
    ms-python.vscode-pylance \
    ms-vscode-remote.remote-containers \
    ms-vsliveshare.vsliveshare \
    nrwl.angular-console \
    openai.chatgpt \
    redhat.java \
    redhat.vscode-xml \
    redhat.vscode-yaml \
    rust-lang.rust-analyzer \
    tamasfe.even-better-toml \
    visualstudioexptteam.intellicode-api-usage-examples \
    visualstudioexptteam.vscodeintellicode \
    vscjava.vscode-gradle \
    vscjava.vscode-java-debug \
    vscjava.vscode-java-dependency \
    vscjava.vscode-java-pack \
    vscjava.vscode-java-test \
    vscjava.vscode-maven" && \
    for EXT in $EXTS; do \
    echo "Installing extension: $EXT" && \
    (openvscode-server --install-extension "$EXT" --force || echo "Failed to install $EXT, continuing..."); \
    done && \
    echo "All extensions installation attempts completed." && \
    rm -rf ~/.vscode-server/extensionsCache && \
    rm -rf ~/.vscode-server/logs && \
    rm -rf /tmp/*
# rm -rf /vsix

CMD [ "openvscode-server" ]