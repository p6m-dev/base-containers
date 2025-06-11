ARG REGISTRY_PREFIX=ybor
FROM ${REGISTRY_PREFIX}/debian:bookworm-slim

ARG VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg && \
    echo "deb https://nginx.org/packages/debian/ bookworm nginx" >> /etc/apt/sources.list && \ 
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    apt-get update && \
    apt-get install nginx=$VERSION.\* && \
    apt-get remove gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
STOPSIGNAL SIGQUIT

CMD [ "nginx", "-g", "daemon off;" ]