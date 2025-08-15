ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/rust:bullseye AS base

ARG BUILDER_IMAGE_TAG
ENV BUILDER_IMAGE_TAG=${BUILDER_IMAGE_TAG}

RUN if [ -z "$BUILDER_IMAGE_TAG" ]; then \
      cargo install --force --git https://github.com/archetect/archetect.git archetect --root /usr/local ; \
    else \
      cargo install --force --git https://github.com/archetect/archetect.git --tag "$BUILDER_IMAGE_TAG" archetect --root /usr/local ; \
    fi
    
FROM ${REGISTRY_PREFIX}/debian:bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git && \
    rm -rf /var/lib/apt/lists/*

COPY --from=base /usr/local/bin/archetect /usr/local/bin/archetect

# Smoke test
RUN archetect --version

ENTRYPOINT ["/usr/local/bin/archetect"]
CMD ["--version"]
