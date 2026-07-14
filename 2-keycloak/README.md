# keycloak

Two image lineages live here during the Bitnami migration (YP6M-2897):

| Directory | Lineage | Layout | Consumers |
|---|---|---|---|
| `26.6.4/` | **Official Keycloak distribution** on the ybor hardened `debian:trixie-slim` base | `/opt/keycloak` | New deployments (p6m-keycloak chart >= 0.2.0) |
| `26.3.1-debian-12-r2/` | Legacy Bitnami-derived (patch layer over our last mirrored Bitnami image) | `/opt/bitnami/keycloak` | Production until migrated — do not remove; the floating `26` tag stays pointed here |

## Official-distribution image (`26.6.4/`)

- Distribution tarball is downloaded from the GitHub release and **sha256-verified**
  (`DIST_SHA256` build arg must be updated in lockstep with `VERSION`).
- Runs an **optimized build** (`kc.sh build`) at image-build time with:
  `--db=postgres --health-enabled=true --metrics-enabled=true --features-disabled=impersonation`
- Runs as non-root UID `1001` (group `0`), `ENTRYPOINT kc.sh`, `CMD start --optimized`.
- Ports: `8080` (http), `8443` (https), `9000` (management — health/metrics).

Because the server is pre-augmented, **runtime env vars for build options are
ignored** (`KC_DB`, `KC_HEALTH_ENABLED`, `KC_METRICS_ENABLED`, `KC_FEATURES_*`).
Runtime options (`KC_DB_URL`, `KC_DB_USERNAME`, `KC_DB_PASSWORD`, `KC_HOSTNAME`,
`KC_HTTP_ENABLED`, `KC_PROXY_HEADERS`, `KC_CACHE_STACK`, `KC_LOG*`, ...) work as usual.

## Baking in provider JARs (downstream images)

Custom SPI providers must be added in a downstream image and the server
**re-augmented with the exact same build flags**, or they will not load under
`start --optimized`:

```dockerfile
FROM ghcr.io/p6m-dev/keycloak:26.6.4
COPY --chown=1001:0 providers/*.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build \
      --db=postgres \
      --health-enabled=true \
      --metrics-enabled=true \
      --features-disabled=impersonation
```

Tag convention: `<keycloak-version>-provider-<provider-version>` (e.g. `26.6.4-provider-1.0.5`).

## Upgrading Keycloak

1. Create `2-keycloak/<new-version>/` from the current official-dist Dockerfile.
2. Update `VERSION` and `DIST_SHA256` (asset digest on the GitHub release page).
3. Add matrix entries in `.github/workflows/build-push.yaml` for the new version tag.
4. Keep the previous version directory until all consumers have moved.
