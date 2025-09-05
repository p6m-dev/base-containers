#!/bin/sh
set -ex

if [ -z "$1" ]; then
    echo "Usage: $0 <openvscode-server|code-server>"
    exit 1
fi

VSCODE="$1"

EXTS="\
    dbaeumer.vscode-eslint \
    docker.docker \
    EchoAPI.echoapi-for-vscode \
    esbenp.prettier-vscode \
    github.copilot \
    github.copilot-chat \
    nrwl.angular-console \
    redhat.vscode-xml \
    redhat.vscode-yaml \
    rust-lang.rust-analyzer \
    tamasfe.even-better-toml" && \
    for EXT in $EXTS; do \
        echo "Installing extension: $EXT" && \
        ($VSCODE --extensions-dir=/vsc/extensions --install-extension "$EXT" --force || echo "Failed to install $EXT, continuing..."); \
    done

echo "All extensions installation attempts completed."
