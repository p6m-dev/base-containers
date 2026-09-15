FROM public.ecr.aws/debian/debian:bullseye AS upgraded

ARG CACHE_BUST
ENV CACHE_BUST=${CACHE_BUST}
ENV TZ=UTC

# bullseye left the mirrors when its LTS ended (2026-08-31): deb.debian.org now 404s its
# security pool, which broke every build of this image (2026-09-15). EOL releases live on
# archive.debian.org, whose Release files no longer refresh — hence Check-Valid-Until off.
# Security comes from snapshot.debian.org at a timestamp just past EOL: the upstream base
# image already carries final security-pool versions (perl-base deb11u5) that archive main
# cannot reconcile, deb.debian.org has dropped the pool files, and bullseye-security has not
# landed on archive.debian.org (probed 2026-09-15: dists/bullseye/Release 200, security 404).
# Frozen releases never refresh their Release files — hence Check-Valid-Until off.
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian-security/20260901T000000Z/ bullseye-security main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-archive-eol

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

# Calculate the sum of all installed packages, which will override Dockercache if something changed
RUN debsums --silent --all --generate=missing && \
    cat /var/lib/dpkg/info/*.md5sums | sha256sum | cut -d' ' -f1 > /var/lib/dpkg/sha256sum

FROM public.ecr.aws/debian/debian:bullseye AS final

ENV TZ=UTC

# This will override the cache if any packages were upgraded
COPY --from=upgraded /var/lib/dpkg/sha256sum /var/lib/dpkg/sha256sum

RUN echo "PKGSUM is $(cat /var/lib/dpkg/sha256sum)"

# Apply the same updates as the upgraded stage
# bullseye left the mirrors when its LTS ended (2026-08-31): deb.debian.org now 404s its
# security pool, which broke every build of this image (2026-09-15). EOL releases live on
# archive.debian.org, whose Release files no longer refresh — hence Check-Valid-Until off.
# Security comes from snapshot.debian.org at a timestamp just past EOL: the upstream base
# image already carries final security-pool versions (perl-base deb11u5) that archive main
# cannot reconcile, deb.debian.org has dropped the pool files, and bullseye-security has not
# landed on archive.debian.org (probed 2026-09-15: dists/bullseye/Release 200, security 404).
# Frozen releases never refresh their Release files — hence Check-Valid-Until off.
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian-security/20260901T000000Z/ bullseye-security main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-archive-eol

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates debsums gpg libssl-dev tzdata wget \
    && rm -rf /var/lib/apt/lists/*

ENV BASE_IMAGE_MAINTAINER="ybor"
ENV BASE_IMAGE_OS="debian"
ENV BASE_IMAGE_OS_VERSION="bullseye"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/dpkg/sha256sum"
