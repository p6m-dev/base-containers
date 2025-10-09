# FROM bitnami/keycloak:26.3.1-debian-12-r2

# DEVNOTE
# Bitnami nuked access to this, so we're simply patching our most recently published container
FROM ghcr.io/p6m-dev/keycloak:26.3.1-debian-12-r2

USER root
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
USER 1001
ENV DISABLE_WELCOME_MESSAGE=true
