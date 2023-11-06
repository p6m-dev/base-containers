FROM ubuntu:jammy AS pkgsum

ARG CACHE_BUST
ENV CACHE_BUST=${CACHE_BUST}

# DEVNOTE: Make sure the list of packages also matches the list below!!
# DEVNOTE: Make sure this is the same as 0-DEBIAN variants for consistency
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

# Calculate the sum of all installed packages, which will override Dockercache if something changed
RUN debsums --silent --all --generate=missing
RUN cat /var/lib/dpkg/info/*.md5sums | sha256sum | cut -d' ' -f1 > /var/lib/dpkg/sha256sum

FROM ubuntu:jammy

# This will override the cache if any packages were upgraded
COPY --from=pkgsum /var/lib/dpkg/sha256sum /var/lib/dpkg/sha256sum

RUN echo "PKGSUM is $(cat /var/lib/dpkg/sha256sum)"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

ENV BASE_IMAGE_MAINTAINER "nax-platform"
ENV BASE_IMAGE_OS "ubuntu"
ENV BASE_IMAGE_OS_VERSION "jammy"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/dpkg/sha256sum"
