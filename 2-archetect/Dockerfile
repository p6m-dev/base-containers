ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/debian:trixie-slim

# DEVNOTE: the following packages are intentionally included to support various Archetect features and or archetect-based workflows.
ENV TZ=UTC
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git curl wget ca-certificates yq jq zip gpg libssl-dev tzdata && \
  rm -rf /var/lib/apt/lists/*

# ARM64: https://github.com/archetect/archetect/releases/download/v2.0.7/archetect-v2.0.7-linux-arm64.tar.gz
# AMD64: https://github.com/archetect/archetect/releases/download/v2.0.7/archetect-v2.0.7-linux-x86_64.tar.gz

ARG BUILDER_IMAGE_TAG=v2.1.0
ENV ARCHETECT_VERSION=${BUILDER_IMAGE_TAG}
RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  amd64) arch='x86_64' ;; \
  armhf) arch='arm64' ;; \
  arm64) arch='arm64' ;; \
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  url="https://github.com/archetect/archetect/releases/download/${ARCHETECT_VERSION}/archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz"; \
  wget "$url"; \
  tar -xzf "archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz" --strip-components=1 -C /usr/local/bin; \
  rm "archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz"; \
  chmod +x /usr/local/bin/archetect; \
  archetect --version;

ENTRYPOINT ["/usr/local/bin/archetect"]
CMD ["--help"]
