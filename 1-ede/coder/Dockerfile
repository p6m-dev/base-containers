ARG VERSION=2.22.1
ARG REGISTRY_PREFIX=ybor
FROM $REGISTRY_PREFIX/ede:nix AS builder

ARG VERSION
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
    x86_64) ARCH_SUFFIX="amd64" ;; \
    aarch64) ARCH_SUFFIX="arm64" ;; \
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    URL="https://github.com/coder/coder/releases/download/v${VERSION}/coder_${VERSION}_linux_${ARCH_SUFFIX}.tar.gz" && \
    echo "Downloading: $URL" && \
    sudo mkdir -p /coder && \
    curl -fsSL "$URL" | sudo tar -xz --strip-components=1 -C /coder && \
    sudo chown -R ede:staff /coder

FROM $REGISTRY_PREFIX/ede:nix
COPY --from=builder /coder/coder /usr/bin/coder
ENTRYPOINT [ "/usr/bin/coder" ]
CMD [ "agent" ]
