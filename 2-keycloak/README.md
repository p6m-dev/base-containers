# keycloak

Two image lineages live here during the Bitnami migration (YP6M-2897); the official-distribution
lineage ships in two database variants:

| Directory | Lineage | Layout | Consumers |
|---|---|---|---|
| `26.6.4/` | **Official Keycloak distribution** on the ybor hardened `debian:trixie-slim` base | `/opt/keycloak` | New deployments (p6m-keycloak chart >= 0.2.0) |
| `26.6.4-mysql/` | **Official Keycloak distribution**, MySQL build variant | `/opt/keycloak` | Deployments on a MySQL backend — prd `auth.ashleyfurniture.com` (YP6M-3053) |
| `26.3.1-debian-12-r2/` | Legacy Bitnami-derived (patch layer over our last mirrored Bitnami image) | `/opt/bitnami/keycloak` | Production until migrated — do not remove; the floating `26` tag stays pointed here |

## Official-distribution image (`26.6.4/`, `26.6.4-mysql/`)

- Distribution tarball is downloaded from the GitHub release and **sha256-verified**
  (`DIST_SHA256` build arg must be updated in lockstep with `VERSION`).
- Runs an **optimized build** (`kc.sh build`) at image-build time with:
  - `26.6.4/` — `--db=postgres --health-enabled=true --metrics-enabled=true --event-metrics-user-enabled=true --features-disabled=impersonation`
  - `26.6.4-mysql/` — `--db=mysql --health-enabled=true --metrics-enabled=true --event-metrics-user-enabled=true --features-disabled=impersonation`
- Runs as non-root UID `1001` (group `0`), `ENTRYPOINT kc.sh`, `CMD start --optimized`.
- Ports: `8080` (http), `8443` (https), `9000` (management — health/metrics).

Because the server is pre-augmented, **runtime env vars for build options are
ignored** (`KC_DB`, `KC_HEALTH_ENABLED`, `KC_METRICS_ENABLED`, `KC_FEATURES_*`,
`KC_EVENT_METRICS_USER_ENABLED`).
Runtime options (`KC_DB_URL`, `KC_DB_USERNAME`, `KC_DB_PASSWORD`, `KC_HOSTNAME`,
`KC_HTTP_ENABLED`, `KC_PROXY_HEADERS`, `KC_CACHE_STACK`, `KC_LOG*`,
`KC_EVENT_METRICS_USER_TAGS`, `KC_EVENT_METRICS_USER_EVENTS`, ...) work as usual.

### Database variants (`--db`), and why there are two tags

`26.6.4` and `26.6.4-mysql` are built from the **same** Keycloak tarball, the same `VERSION`,
the same `DIST_SHA256` and the same four non-`--db` flags. They differ in exactly one thing:

| Tag | `kc.sh build --db=` |
|---|---|
| `26.6.4` | `postgres` |
| `26.6.4-mysql` | `mysql` |

`kc.sh build --db=` accepts exactly one vendor, so Keycloak cannot produce a multi-vendor
optimized image, and under `start --optimized` the `KC_DB` runtime env var is ignored.
**Which tag you deploy is therefore a deployment decision driven by the consuming chart's
database backend, not a runtime switch.** Pointing a MySQL-backed install at the postgres
tag does not fall back or warn — it fails to start.

Keycloak bundles the JDBC drivers for every supported vendor except Oracle, so neither
variant needs a driver JAR dropped in (verified on `26.6.4-mysql`:
`com.mysql.mysql-connector-j-9.6.0.jar` ships in `/opt/keycloak/lib/lib/main/`).

Keep the two Dockerfiles in lockstep — any change to `VERSION`, `DIST_SHA256` or the flag
list must be made in both.

#### MySQL operational note

Azure Database for MySQL Flexible Server installs use a JDBC URL carrying
`?characterEncoding=UTF-8&sessionVariables=sql_generate_invisible_primary_key=OFF`. Setting
that session variable requires the connecting user to hold **`SESSION_VARIABLES_ADMIN`**
(or `SUPER`). A least-privilege application user without it fails at startup with
`Access denied; you need (at least one of) the SUPER, SYSTEM_VARIABLES_ADMIN or
SESSION_VARIABLES_ADMIN privilege(s)` — a database-grant problem, not an image problem.

### User event metrics

`--event-metrics-user-enabled=true` is baked in (YP6M-3411), replacing the Aerogear
`keycloak-metrics-spi` (`metrics-listener`) that the Bitnami lineage shipped and this
image does not. It emits a `keycloak_user_events_total` counter on the same
`:9000/metrics` endpoint.

Two things that are easy to get wrong:

- It needs **no** `--features=user-event-metrics`. That feature is `Type.DEFAULT`
  (supported, on by default) as of Keycloak 26.2 — it was only preview in 26.1.
- Its listener, `micrometer-user-event-metrics`, declares `isGlobal() == true`, so it
  fires for every realm and must **not** be added to a realm's `eventsListeners`.
  Naming it there is not required and naming a listener the server lacks makes
  `PUT /admin/realms/{realm}/events/config` fail with `400 Unknown event listener`.

Counters reset when an instance restarts, so aggregate across the cluster. The
`clientId` and `error` tags are capped at 10,000 unique values by default; the tag set
defaults to `realm` only and is widened at runtime via `KC_EVENT_METRICS_USER_TAGS`.

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
      --event-metrics-user-enabled=true \
      --features-disabled=impersonation
```

The MySQL variant needs its own downstream image with `--db` changed to match its base —
a downstream that re-augments `26.6.4-mysql` with `--db=postgres` **silently reverts the
image to postgres**:

```dockerfile
FROM ghcr.io/p6m-dev/keycloak:26.6.4-mysql
COPY --chown=1001:0 providers/*.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build \
      --db=mysql \
      --health-enabled=true \
      --metrics-enabled=true \
      --event-metrics-user-enabled=true \
      --features-disabled=impersonation
```

`kc.sh build` persists exactly the options it is given — anything omitted reverts to
its default. A downstream re-augmentation that drops a flag therefore silently turns
that option **off**, which is why the list has to be copied whole rather than trimmed.

Tag convention: `<keycloak-version>-provider-<provider-version>` (e.g. `26.6.4-provider-1.0.5`).

## Upgrading Keycloak

1. Create `2-keycloak/<new-version>/` **and** `2-keycloak/<new-version>-mysql/` from the
   current official-dist Dockerfiles. Both variants move together.
2. Update `VERSION` and `DIST_SHA256` (asset digest on the GitHub release page) in both.
3. Add matrix entries in `.github/workflows/build-push.yaml` for both new version tags.
4. Confirm the only difference between the two Dockerfiles is the `--db` value:
   `diff <(tail -n +19 2-keycloak/<new-version>-mysql/Dockerfile) 2-keycloak/<new-version>/Dockerfile`
5. Keep the previous version directories until all consumers have moved.
