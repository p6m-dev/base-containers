ARG REGISTRY_PREFIX=ybor

# kubectl for Helm hook Jobs and other script-shaped consumers, as a drop-in replacement for
# bitnami/kubectl (no longer served by Docker Hub). Those scripts run under `/bin/bash -c` and
# pipe through awk and wc, which is why this is a Debian image and not registry.k8s.io/kubectl:
# that one is distroless and has no shell.

# ---------------------------------------------------------------------------
# Fetch stage: download the upstream release binary and verify it against the pins below.
# Kept separate so curl never ships in the final image.
# ---------------------------------------------------------------------------
FROM ${REGISTRY_PREFIX}/debian:trixie-slim AS fetch

RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl && \
  rm -rf /var/lib/apt/lists/*

# VERSION is the workflow's general-purpose version build-arg (matrix.version_arg). One minor
# version serves the fleet: kubectl supports API servers one minor older or newer than itself.
ARG VERSION=v1.36.4

# The exact bytes that VERSION means, per architecture, pinned here rather than read from the
# .sha256 file published next to the binary: whoever can replace one can replace both. Bumping
# VERSION means bumping these together. To get them, download each binary and hash it:
#   curl -sfL https://dl.k8s.io/release/<version>/bin/linux/<amd64|arm64>/kubectl | sha256sum
# and check the result matches the published <url>.sha256 before pasting it here.
ARG SHA256_AMD64=8b8f088da2dab964f853b38464033b1be15ede2839eca751482357c45abdd05a
ARG SHA256_ARM64=0ecf44450ee6063bf19dd166a103ee6df4a9034455c2abce626e6eea657d73fb

RUN set -eux; \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
  amd64) arch='amd64'; sha256="${SHA256_AMD64}" ;; \
  arm64) arch='arm64'; sha256="${SHA256_ARM64}" ;; \
  *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
  esac; \
  # Fail closed on an unpinned version: overriding VERSION without its checksums would
  # otherwise install whatever that URL happens to serve.
  if [ -z "${sha256}" ]; then \
  echo >&2 "no pinned SHA256 for kubectl ${VERSION} on ${arch}; pass SHA256_AMD64/SHA256_ARM64 for that release"; \
  exit 1; \
  fi; \
  curl -sfL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/${arch}/kubectl"; \
  echo "${sha256}  /usr/local/bin/kubectl" | sha256sum -c -; \
  chmod 0755 /usr/local/bin/kubectl

# ---------------------------------------------------------------------------
# Runtime stage
# ---------------------------------------------------------------------------
FROM ${REGISTRY_PREFIX}/debian:trixie-slim

ARG VERSION=v1.36.4
ENV KUBECTL_VERSION=${VERSION}

COPY --from=fetch /usr/local/bin/kubectl /usr/local/bin/kubectl

# nobody:nogroup, the identity the kyverno chart's hook securityContext already forces. Hooks
# also run with a read-only root filesystem, so kubectl cannot write its discovery cache under
# HOME and has to work without one.
USER 65534:65534

# smoke test: the binary runs, and the tools the hook scripts call are present
RUN kubectl version --client && bash -c 'echo ok | awk "{print}" | wc -l'

# Same entrypoint as bitnami/kubectl, so consumers that set only `args` keep working.
ENTRYPOINT ["kubectl"]
