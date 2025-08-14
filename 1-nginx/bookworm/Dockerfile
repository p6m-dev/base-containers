ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/debian:bookworm-slim

ARG VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates libssl-dev && \
    echo "deb https://nginx.org/packages/debian/ bookworm nginx" >> /etc/apt/sources.list && \ 
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 2FD21310B49F6B46 && \
    apt-get update && \
    apt-get install nginx=$VERSION.\* -y --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
STOPSIGNAL SIGQUIT

CMD [ "nginx", "-g", "daemon off;" ]