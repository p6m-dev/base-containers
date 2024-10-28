FROM ybor/debian:bullseye

ARG VERSION

RUN echo "deb https://nginx.org/packages/debian/ bullseye nginx" >> /etc/apt/sources.list && \ 
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    apt-get update && \
    apt-get install -y nginx=$VERSION.\* && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
STOPSIGNAL SIGQUIT

CMD [ "nginx", "-g", "daemon off;" ]