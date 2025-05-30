ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/debian:bullseye AS base

ARG VERSION="2025.2.1"
ENV VERSION=${VERSION}

RUN ARCH=$(dpkg --print-architecture) && \
    wget "https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${ARCH}" && \
    chmod +x cloudflared-linux-${ARCH} && \
    mv cloudflared-linux-${ARCH} /bin/cloudflared

FROM ybor/debian:bullseye 
COPY --from=base /bin/cloudflared /bin/cloudflared

# smoke test
RUN cloudflared --version

ENTRYPOINT ["/bin/cloudflared"]
CMD ["--version"]