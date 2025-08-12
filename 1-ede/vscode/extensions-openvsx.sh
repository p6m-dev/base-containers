#!/bin/sh
set -ex

if [ -z "$1" ]; then
    echo "Usage: $0 <openvscode-server|code-server>"
    exit 1
fi

VSCODE="$1"

EXTS="\
    anthropic.claude-code \
    bradlc.vscode-tailwindcss \
    dbaeumer.vscode-eslint \
    docker.docker \
    esbenp.prettier-vscode \
    firsttris.vscode-jest-runner \
    formulahendry.auto-close-tag \
    formulahendry.auto-rename-tag \
    github.copilot \
    github.copilot-chat \
    github.vscode-github-actions \
    golang.go \
    mikestead.dotenv \
    ms-azuretools.vscode-containers \
    ms-azuretools.vscode-docker \
    ms-dotnettools.csdevkit \
    ms-dotnettools.csharp \
    ms-dotnettools.vscode-dotnet-runtime \
    ms-playwright.playwright \
    ms-python.debugpy \
    ms-python.python \
    ms-python.vscode-pylance \
    ms-vscode-remote.remote-containers \
    ms-vsliveshare.vsliveshare \
    nrwl.angular-console \
    openai.chatgpt \
    redhat.java \
    redhat.vscode-xml \
    redhat.vscode-yaml \
    rust-lang.rust-analyzer \
    tamasfe.even-better-toml \
    visualstudioexptteam.intellicode-api-usage-examples \
    visualstudioexptteam.vscodeintellicode \
    vscjava.vscode-gradle \
    vscjava.vscode-java-debug \
    vscjava.vscode-java-dependency \
    vscjava.vscode-java-pack \
    vscjava.vscode-java-test \
    vscjava.vscode-maven" && \
    for EXT in $EXTS; do \
        echo "Installing extension: $EXT" && \
        ($VSCODE --install-extension "$EXT" --force || echo "Failed to install $EXT, continuing..."); \
    done

echo "All extensions installation attempts completed."
rm -rf ~/.vscode-server/extensionsCache
rm -rf ~/.vscode-server/logs
