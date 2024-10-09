ARG IMAGE_TAG
FROM p6m-dev/rust:${IMAGE_TAG}
ARG VERSION
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Sourced from:
# https://github.com/LukeMathWalker/cargo-chef/blob/main/docker/Dockerfile

# Install musl-dev on Alpine to avoid error "ld: cannot find crti.o: No such file or directory"
RUN ((cat /etc/os-release | grep ID | grep alpine) && apk add --no-cache musl-dev || true) \
    && cargo install cargo-chef --locked --version $VERSION \
    && rm -rf $CARGO_HOME/registry/
