ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/rust:bullseye AS base

RUN cargo install --force --git https://github.com/archetect/archetect.git archetect --root /usr/local

FROM ${REGISTRY_PREFIX}/debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        jq \
        zip && \
    rm -rf /var/lib/apt/lists/*

COPY --from=base /usr/local/bin/archetect /usr/local/bin/archetect

# Smoke test
RUN archetect --version

ENTRYPOINT ["/usr/local/bin/archetect"]
CMD ["--version"]
