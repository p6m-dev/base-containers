FROM naxgrp/debian:bullseye

ARG VERSION

RUN wget -qO - https://deb.nodesource.com/setup_${VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
