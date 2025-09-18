#!/bin/sh
set -ex

if [ -z "$1" ]; then
    echo "Usage: $0 <openvscode-server|code-server>"
    exit 1
fi

IDE="$1"

export EDE_VSCODE_RELEASE=$(curl -s https://api.github.com/repos/ybor-studio/ede-vscode/releases/latest | jq -r .tag_name)
echo "EDE-VScode Latest release: $EDE_VSCODE_RELEASE"

curl -L -o /tmp/ede-vscode.vsix "https://github.com/ybor-studio/ede-vscode/releases/download/$EDE_VSCODE_RELEASE/ede-vscode-$EDE_VSCODE_RELEASE.vsix"

echo "Installing EDE-VScode extension on ${IDE}..."
$IDE --server-data-dir /code-server \
     --builtin-extensions-dir /code-server/extensions \
     --enable-proposed-api ybor-studio.ede-vscode \
     --install-builtin-extension /tmp/ede-vscode.vsix \
     --force

echo "EDE-VScode extension installed successfully."
