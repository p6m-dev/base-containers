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
    wget \
    bash \
    sudo \
    dnsmasq

COPY ./init.sh /init.sh
ENTRYPOINT [ "/init.sh" ]