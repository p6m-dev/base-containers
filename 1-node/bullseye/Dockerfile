FROM p6m-dev/debian:bullseye

ARG VERSION

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN wget -qO - https://deb.nodesource.com/setup_${VERSION}.x | bash - && \
    apt-get install -y nodejs gcc g++ make && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
