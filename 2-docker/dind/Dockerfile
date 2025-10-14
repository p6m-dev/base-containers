FROM docker:dind

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        iptables \
        iproute2 \
        iputils \
        busybox-extras \
        bind-tools \
        curl \
        wget
