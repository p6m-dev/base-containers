ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/ede:nix

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
    dbaeumer.vscode-eslint \
    esbenp.prettier-vscode \
    firsttris.vscode-jest-runner \
    nrwl.angular-console \
    tamasfe.even-better-toml \
    anthropic.claude-code \
    docker.docker \
    github.copilot \
    github.copilot-chat \
    github.vscode-github-actions \
    hashicorp.terraform \
    ms-azuretools.vscode-containers \
    ms-azuretools.vscode-docker \
    ms-dotnettools.vscode-dotnet-runtime \
    ms-vscode-remote.remote-containers \
    redhat.java \
    redhat.vscode-xml \
    redhat.vscode-yaml \
    rust-lang.rust-analyzer \
    rvest.vscode-prettier-eslint \
    streetsidesoftware.code-spell-checker \
    stylelint.vscode-stylelint \
    visualstudioexptteam.intellicode-api-usage-examples \
    visualstudioexptteam.vscodeintellicode \
    vscjava.vscode-gradle \
    vscjava.vscode-java-debug \
    vscjava.vscode-java-dependency \
    vscjava.vscode-java-pack \
    vscjava.vscode-java-test \
    vscjava.vscode-maven \
    bradlc.vscode-tailwindcss \
    dsznajder.es7-react-js-snippets \
    eamodio.gitlens \
    fill-labs.dependi \
    formulahendry.auto-close-tag \
    formulahendry.auto-rename-tag \
    golang.go \
    gruntfuggly.todo-tree \
    mikestead.dotenv \
    ms-dotnettools.csdevkit \
    ms-dotnettools.csharp \
    ms-playwright.playwright \
    ms-python.debugpy \
    ms-python.python \
    ms-python.vscode-pylance \
    ms-vsliveshare.vsliveshare \
    openai.chatgpt \
    rhai-script.vscode-rhai" && \
    for EXT in $EXTS; do \
    echo "Installing extension: $EXT" && \
    openvscode-server --install-extension "$EXT"; \
    done && \
    echo "All extensions installed successfully." && \
    rm -rf ~/.vscode-server/extensionsCache && \
    rm -rf ~/.vscode-server/logs && \
    rm -rf /tmp/*

CMD [ "openvscode-server" ]