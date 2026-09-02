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
# 3.5.0 is the floor for Studio's generation surface: DescribeArchetype takes the answers
# collected so far, which is what lets a client render an archetype's prompts as a wizard
# (describe → the page that still has prompts → collect → describe again). Below it, a
# describe can only ever return the whole prompt surface at once.
# 3.6.0 adds eager serving (YP6M-3652): `archetect server` warms its catalog before binding
# the port and re-checks every source on `updates.refresh_interval`, so request paths never
# pause on the network — the chart's invalidate+pull entrypoint hack retires with it.
ARG VERSION=v3.6.0
ENV ARCHETECT_VERSION=${VERSION}

# The exact bytes that VERSION means, per architecture. Pinned HERE rather than fetched
# alongside the tarball: a checksum published next to the artifact it describes is vouched for
# by nobody, so whoever can replace one can replace both, and verifying against it proves only
# that the download was not corrupted in transit. Pinned, the version tag becomes a CONTENT
# pin — the binary in this image is the one reviewed when this line was written, or the build
# fails. That is the difference between "we asked for 3.5.0" and "we got 3.5.0".
#
# Bumping VERSION means bumping these together. The release publishes them:
#   gh release download <tag> -R archetect/archetect -p '*linux*.sha256' -O -
# (verified against the downloaded artifacts on 2026-09-02, not merely copied from that file).
ARG SHA256_X86_64=0b9b56aeaae70a0fc1a74d8d73bb5a69f40f9d47217fc4fd0a30f631b6fe03e6
ARG SHA256_ARM64=4b746711a4fe05ad3add5e9245ef96881432df667fcb7ca8bdf94fdbed791740

RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  amd64) arch='x86_64'; sha256="${SHA256_X86_64}" ;; \
  arm64) arch='arm64'; sha256="${SHA256_ARM64}" ;; \
  # armhf deliberately NOT mapped to arm64: a 32-bit userland cannot run the arm64 binary,
  # and the published platforms are amd64/arm64 only — an armhf build fails here by name.
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  # Fail CLOSED on an unpinned version: overriding VERSION without its checksums would
  # otherwise install whatever that tag happens to serve, which is the hole this closes.
  if [ -z "${sha256}" ]; then \
  echo >&2 "no pinned SHA256 for ${ARCHETECT_VERSION} on ${arch} — pass SHA256_X86_64/SHA256_ARM64 for that release"; \
  exit 1; \
  fi; \
  tarball="archetect-${ARCHETECT_VERSION}-linux-${arch}.tar.gz"; \
  url="https://github.com/archetect/archetect/releases/download/${ARCHETECT_VERSION}/${tarball}"; \
  wget -q "$url"; \
  echo "${sha256}  ${tarball}" | sha256sum -c -; \
  tar -xzf "${tarball}" --strip-components=1 -C /usr/local/bin; \
  rm "${tarball}"; \
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
