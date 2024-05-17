# Args available to FROM directives
# Runner Versions: https://github.com/actions/runner/pkgs/container/actions-runner
ARG VERSION=latest

FROM ghcr.io/actions/actions-runner:${VERSION}

# Args available to all directives in this stage
# NVM versions: https://github.com/nvm-sh/nvm/releases
ARG NVM_VERSION=0.39.7

RUN sudo apt update -y && sudo apt install -y git curl jq

# Install latest LTS version of Node.js
ENV NVM_DIR=/home/runner/.nvm
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh -o /tmp/install_nvm.sh && \
    bash /tmp/install_nvm.sh && \
    rm /tmp/install_nvm.sh && \
    . ~/.nvm/nvm.sh && \
    nvm install --lts
