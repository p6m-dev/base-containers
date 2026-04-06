ARG IMAGE_TAG
FROM rust:${IMAGE_TAG}
ARG VERSION
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Sourced from:
# https://github.com/LukeMathWalker/cargo-chef/blob/main/docker/Dockerfile

# Install musl-dev on Alpine to avoid error "ld: cannot find crti.o: No such file or directory"
RUN ((cat /etc/os-release | grep ID | grep alpine) && apk add --no-cache musl-dev || true) \
    && cargo install cargo-chef --locked --version $VERSION \
    && rm -rf $CARGO_HOME/registry/

ARG SCCACHE_VERSION=0.14.0
ARG TARGETARCH
RUN case "$TARGETARCH" in \
        arm64) SCCACHE_ARCH="aarch64-unknown-linux-musl" ;; \
        amd64) SCCACHE_ARCH="x86_64-unknown-linux-musl" ;; \
    esac && \
    curl -fsSL https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local/bin \
    sccache-v${SCCACHE_VERSION}-${SCCACHE_ARCH}/sccache && sccache --help
ENV RUSTC_WRAPPER=sccache
