FROM naxgrp/ubuntu:jammy

ARG VERSION
ENV LANG=C.UTF-8

# pipx bin
RUN mkdir -p "${HOME}/.local/bin"
ENV PATH="${PATH}:${HOME}/.local/bin"

RUN echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes.list && \
    echo "deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main" >> /etc/apt/sources.list.d/deadsnakes.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 && \
    apt-get update && \
    apt-get install -y curl python${VERSION} python${VERSION}-dev python${VERSION}-venv && \
    curl -fsSL https://github.com/pypa/get-pip/raw/4cfa4081d27285bda1220a62a5ebf5b4bd749cdb/public/get-pip.py | python${VERSION} && \
    pip install --no-cache-dir pipx==1 && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python${VERSION} 1

# Smoke tests
RUN python --version
RUN pipx --version
RUN pip --version
RUN python -m venv --help

CMD ["python"]
