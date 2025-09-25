ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/ubuntu:noble

ARG VERSION_ARG=f220831ea2d946c0dcb0f3eaa480eb435a2c1260 # https://github.com/microsoft/vscode/releases/tag/1.104.0
ENV VSCODE_COMMIT_SHA=${VERSION_ARG}

# code-server
# TODO: look up sha from github releases
# AMD64: https://vscode.download.prss.microsoft.com/dbazure/download/stable/${VSCODE_COMMIT_SHA}/vscode-server-linux-x64-web.tar.gz
# ARM64: https://vscode.download.prss.microsoft.com/dbazure/download/stable/${VSCODE_COMMIT_SHA}/vscode-server-linux-arm64-web.tar.gz

RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
    apt-get update && \
    apt-get install -y code-insiders curl && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
    x86_64) ARCH_SUFFIX="x64" ;; \
    aarch64) ARCH_SUFFIX="arm64" ;; \
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    mkdir -p /code-server && \
    URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/${VSCODE_COMMIT_SHA}/vscode-server-linux-$ARCH_SUFFIX-web.tar.gz" && \
    echo "Downloading: $URL" && \
    curl -fsSL "$URL" | tar -xz --strip-components=1 -C /code-server

ENV PATH="/code-server/bin:$PATH"
RUN code-server --version

ENTRYPOINT [ "code-server" ]
CMD [ "--accept-server-license-terms", "--host", "0.0.0.0", "--port", "2999" ]
EXPOSE 2999