ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/debian:trixie-slim

# Archetect v3, server-shaped (YP6M-3288): runs `archetect server` (gRPC :8080) by
# default for long-lived deployments; job-style consumers (Argo render workflows, EDE
# init containers) override the command and get the same CLI the v2 image provided.
# The v2 tool set is intentionally retained for those workflows (bsdtar, jq, zip, ...).
ENV TZ=UTC
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git curl wget ca-certificates yq jq zip unzip libarchive-tools gpg libssl-dev tzdata && \
  rm -rf /var/lib/apt/lists/*

# VERSION is the workflow's general-purpose version build-arg (matrix.version_arg).
ARG VERSION=v3.4.3
ENV ARCHETECT_VERSION=${VERSION}
RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  amd64) arch='x86_64' ;; \
  armhf | arm64) arch='arm64' ;; \
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  url="https://github.com/archetect/archetect/releases/download/${ARCHETECT_VERSION}/archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz"; \
  wget -q "$url"; \
  tar -xzf "archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz" --strip-components=1 -C /usr/local/bin; \
  rm "archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz"; \
  chmod +x /usr/local/bin/archetect; \
  archetect --version

# Non-root. All three XDG trees (config, cache, data) live under HOME and must be
# writable: the git cache materializes archetype trees at render time. Catalog
# configuration is file-only — mount it at /home/archetect/.config/archetect/archetect.yaml.
RUN useradd --create-home --uid 10001 archetect && \
  mkdir -p /home/archetect/workspace && \
  chown -R archetect:archetect /home/archetect
USER archetect
ENV HOME=/home/archetect
# The server absorbs an archetect.yaml from its CWD, silently replacing the configured
# catalog — pin the working directory to one deployments keep empty.
WORKDIR /home/archetect/workspace

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/archetect"]
CMD ["server"]
