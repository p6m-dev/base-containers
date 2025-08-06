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
CMD [ "openvscode-server" ]