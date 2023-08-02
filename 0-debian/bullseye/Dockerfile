FROM debian:bullseye AS pkgsum

ARG CACHE_BUST
ENV CACHE_BUST=${CACHE_BUST}

# DEVNOTE: Make sure the list of packages also matches the list below!!
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

# Calculate the sum of all installed packages, which will override Dockercache if something changed
RUN debsums --silent --all --generate=missing
RUN cat /var/lib/dpkg/info/*.md5sums | sha256sum | cut -d' ' -f1 > /var/lib/dpkg/info/sha256sum

FROM debian:bullseye

# This will override the cache if any packages were upgraded
COPY --from=pkgsum /var/lib/dpkg/info/sha256sum /var/lib/dpkg/info/sha256sum

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

ENV BASE_IMAGE_MAINTAINER "nax-platform"
