# DEVNOTE
# As soon as bitnami stops publishing keycloak:26, switch this to FROM ybor/keycloak:26
FROM bitnami/keycloak:26

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/* && \
    # Overrides:
    mv /opt/bitnami/scripts/libkeycloak.sh /opt/bitnami/scripts/libkeycloak-ext.sh

COPY rootfs/opt/bitnami/scripts/libkeycloak.sh /opt/bitnami/scripts/libkeycloak.sh
USER 1001
ENV DISABLE_WELCOME_MESSAGE=true
