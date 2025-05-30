FROM ubuntu:noble AS upgraded

ARG CACHE_BUST
ENV CACHE_BUST=${CACHE_BUST}
ENV TZ=UTC

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

# Calculate the sum of all installed packages, which will override Dockercache if something changed
RUN debsums --silent --all --generate=missing && \
    cat /var/lib/dpkg/info/*.md5sums | sha256sum | cut -d' ' -f1 > /var/lib/dpkg/sha256sum

FROM upgraded AS final

# This will override the cache if any packages were upgraded
COPY --from=upgraded /var/lib/dpkg/sha256sum /var/lib/dpkg/sha256sum

RUN echo "PKGSUM is $(cat /var/lib/dpkg/sha256sum)"

ENV BASE_IMAGE_MAINTAINER "ybor"
ENV BASE_IMAGE_OS "ubuntu"
ENV BASE_IMAGE_OS_VERSION "noble"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/dpkg/sha256sum"
