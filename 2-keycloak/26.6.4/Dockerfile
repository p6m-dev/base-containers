ARG REGISTRY_PREFIX=ybor

# ---------------------------------------------------------------------------
# Build stage: fetch the official Keycloak distribution, verify its checksum,
# and produce an optimized (pre-augmented) server.
#
# Build options are BAKED into the image here. Consumers must run
# `start --optimized`, and runtime env vars for build options (KC_DB,
# KC_HEALTH_ENABLED, KC_METRICS_ENABLED, KC_FEATURES_DISABLED) are ignored.
# Downstream images that add provider JARs MUST re-run `kc.sh build` with
# these exact same flags (see 2-keycloak/README.md).
# ---------------------------------------------------------------------------
FROM ${REGISTRY_PREFIX}/debian:trixie-slim AS build

ARG VERSION=26.6.4
# sha256 of keycloak-${VERSION}.tar.gz from the GitHub release asset digest.
# Must be updated in lockstep with VERSION.
ARG DIST_SHA256=386b566bbea05527226e275c43e5cf6f218896ad2441ac4be5c39f1226772e8f

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    openjdk-21-jre-headless \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/keycloak.tar.gz \
      "https://github.com/keycloak/keycloak/releases/download/${VERSION}/keycloak-${VERSION}.tar.gz" && \
    echo "${DIST_SHA256}  /tmp/keycloak.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    mv /opt/keycloak-${VERSION} /opt/keycloak && \
    rm /tmp/keycloak.tar.gz

RUN /opt/keycloak/bin/kc.sh build \
      --db=postgres \
      --health-enabled=true \
      --metrics-enabled=true \
      --features-disabled=impersonation

# ---------------------------------------------------------------------------
# Runtime stage
# ---------------------------------------------------------------------------
FROM ${REGISTRY_PREFIX}/debian:trixie-slim

LABEL MAINTAINER="ybor"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    openjdk-21-jre-headless \
    && rm -rf /var/lib/apt/lists/* && \
    useradd --system --uid 1001 --gid 0 --home-dir /opt/keycloak --shell /usr/sbin/nologin keycloak

COPY --from=build --chown=1001:0 /opt/keycloak /opt/keycloak

# Group-writable so downstream provider images can re-augment as USER 1001
RUN chmod -R g+rwX /opt/keycloak

ENV LANG=C.UTF-8 \
    KC_RUN_IN_CONTAINER=true \
    PATH="/opt/keycloak/bin:${PATH}"

USER 1001

# smoke test
RUN kc.sh --version

EXPOSE 8080 8443 9000

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
