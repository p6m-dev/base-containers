FROM alpine:3.17 as pkgsum

ARG CACHE_BUST
ENV CACHE_BUST=${CACHE_BUST}
ENV TZ=UTC

# Make sure this command matches the one below EXACTLY
RUN apk update && \
    apk upgrade --no-cache

# Calculate the sum of all installed packages, which will override Docker cache if something changed
RUN mkdir -p /var/lib/apk/
RUN apk info -vv | awk '/^\/[^\/]/{print $1}' | xargs sha256sum | sha256sum | cut -d ' ' -f 1 > /var/lib/apk/sha256sum

FROM alpine:3.17

ENV TZ=UTC

# This will override the cache if any packages were upgraded
COPY --from=pkgsum /var/lib/apk/sha256sum /var/lib/apk/sha256sum

RUN echo "PKGSUM is $(cat /var/lib/apk/sha256sum)"

# Make sure this command matches the one above EXACTLY
RUN apk update && \
    apk upgrade --no-cache

ENV BASE_IMAGE_MAINTAINER "ybor"
ENV BASE_IMAGE_OS "alpine"
ENV BASE_IMAGE_OS_VERSION "3.17"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/apk/sha256sum"
