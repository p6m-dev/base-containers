ARG IMAGE_TAG="bullseye"
FROM naxgrp/debian:${IMAGE_TAG}
ARG version="1.36.0"

## Sourced from
## https://github.com/mapbox/tippecanoe/blob/master/Dockerfile
## https://github.com/naturalsolutions/Tippecanoe/pull/2/files

WORKDIR /home/tippecanoe

# Update repos and install dependencies
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install build-essential libsqlite3-dev zlib1g-dev

RUN mkdir /input
RUN mkdir /output

# Build tippecanoe
RUN apt-get -y install git g++ make \
  && cd /root \
  && git clone --depth=1 --branch=${version} https://github.com/mapbox/tippecanoe.git tippecanoe \
  && cd tippecanoe \
  && make \
  && make install \
  && rm -rf /root/tippecanoe \
  && apt remove -y git g++ make \
  && apt -y clean \
  && apt -y autoremove

# Configure Entrypoint
CMD ["/usr/local/bin/tippecanoe"]