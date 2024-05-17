# Runner Versions: https://github.com/actions/runner/pkgs/container/actions-runner
ARG VERSION=latest
# NVM versions: https://github.com/nvm-sh/nvm/releases
ARG NVM_VERSION=0.39.7

FROM ghcr.io/actions/actions-runner:${VERSION}

RUN sudo apt update -y && sudo apt install -y git curl jq

# Install latest LTS version of Node.js
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh -o /tmp/install_nvm.sh && \
    bash /tmp/install_nvm.sh && \
    rm /tmp/install_nvm.sh && \
    source .bashrc && \
    nvm install --lts
