FROM public.ecr.aws/docker/library/alpine:3.17 as upgraded

ENV TZ=UTC

# Update and upgrade packages
RUN apk update && apk upgrade --no-cache

# Calculate the sum of all installed packages, which will override Docker cache if something changed
RUN mkdir -p /var/lib/apk/ && \
    apk info -vv | awk '/^\/[^\/]/{print $1}' | xargs sha256sum | sha256sum | cut -d ' ' -f 1 > /var/lib/apk/sha256sum

FROM public.ecr.aws/docker/library/alpine:3.17 AS final

# This will override the cache if any packages were upgraded
COPY --from=upgraded /var/lib/apk/sha256sum /var/lib/apk/sha256sum

# Echo the package sum for cache validation
RUN echo "PKGSUM is $(cat /var/lib/apk/sha256sum)"

# Apply the same updates as the upgraded stage
RUN apk update && apk upgrade --no-cache

ENV BASE_IMAGE_MAINTAINER="ybor"
ENV BASE_IMAGE_OS="alpine"
ENV BASE_IMAGE_OS_VERSION="3.17"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/apk/sha256sum"
