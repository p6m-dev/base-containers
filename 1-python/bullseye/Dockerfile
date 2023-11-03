FROM naxgrp/debian:bullseye-82c146d

ARG PYTHON_MAJOR=3
ARG PYTHON_MINOR=11
ARG PYTHON_PATCH=6

# Define environment variables to avoid interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV BASE_IMAGE_MAINTAINER "nax-platform"
ENV BASE_IMAGE_OS "debian"
ENV BASE_IMAGE_OS_VERSION "python:${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}"
ENV BASE_IMAGE_OS_PKGSUM_FILE="/var/lib/dpkg/sha256sum"

# # Kept throwing a 404 during installation, might have been a temporary issue
# # Source (https://github.com/deadsnakes/python3.11/actions/runs/6605635320/job/17941039921)
# # https://keyserver.ubuntu.com/pks/lookup?search=asottile%2Bdeadsnakes%40umich.edu&fingerprint=on&op=index
# ARG GPG_KEY_ID=555eb989bfc45c8464fd3bfae985eef656d23992

# RUN apt-get update \
#   && apt-get install -y ca-certificates software-properties-common --no-install-recommends \
#   && add-apt-repository "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu bullseye main" \
#   && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${GPG_KEY_ID} \
#   && rm -rf /var/lib/apt/lists/* \
#   && apt-get update \
#   && apt-get install -y python${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH} python${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}-dev python${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}-venv \

# Install the dependencies required for compiling Python
RUN apt-get update && apt-get install -y \
  wget \
  build-essential \
  libffi-dev \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libncurses5-dev \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  liblzma-dev \
  libgdbm-dev \
  libnss3-dev \
  libgdbm-compat-dev \
  uuid-dev \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Download and install Python 3.11 from source
RUN wget https://www.python.org/ftp/python/${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}/Python-${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}.tgz \
  && tar -xzf Python-${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}.tgz \
  && cd Python-${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH} \
  && ./configure --enable-optimizations \
  && make -j $(nproc) \
  && make altinstall \
  && cd .. \
  && rm -rf Python-${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}.tgz Python-${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}

# Make some useful symlinks that are expected to exist
RUN ln -s /usr/local/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH} /usr/local/bin/python3 \
  && ln -s /usr/local/bin/pip${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH} /usr/local/bin/pip3 \
  && ln -s /usr/local/bin/pydoc${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH} /usr/local/bin/pydoc3

# If you want to make Python 3.11 the default Python, uncomment these lines:
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python${PYTHON_MAJOR}.${PYTHON_MINOR} 1 \
  && update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip${PYTHON_MAJOR}.${PYTHON_MINOR} 1

# Python Core Tooling
RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py | python
RUN pip install --no-cache-dir pipx supervisor supervisor_checks amazon-kclpy
ENV PATH="${PATH}:/root/.local/bin"
RUN pipx install awscli 
RUN pipx install awscliv2
RUN pipx install awscli-local 

# Log Redirection
RUN mkdir -p /var/log/supervisor
RUN touch /var/log/supervisor/services.log

# Calculate the sum of all installed packages, which will override Dockercache if something changed
RUN debsums --silent --all --generate=missing
RUN cat /var/lib/dpkg/info/*.md5sums | sha256sum | cut -d' ' -f1 > /var/lib/dpkg/sha256sum

# This will override the cache if any packages were upgraded
# COPY --from=pkgsum /var/lib/dpkg/sha256sum /var/lib/dpkg/sha256sum
RUN echo "PKGSUM is $(cat /var/lib/dpkg/sha256sum)"

# Set the default command for the container to python3.11
CMD ["python${PYTHON_MAJOR}.${PYTHON_MINOR}.${PYTHON_PATCH}"]
