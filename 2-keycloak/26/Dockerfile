# DEVNOTE
# As soon as bitnami stops publishing keycloak:26, switch this to FROM ybor/keycloak:26
FROM bitnami/keycloak:26

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

USER 1001
