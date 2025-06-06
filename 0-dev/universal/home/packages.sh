#!/bin/bash
set -euo pipefail

# Detect architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_SUFFIX="amd64"; ALT_ARCH_SUFFIX="x86_64" ;;
    aarch64) ARCH_SUFFIX="arm64"; ALT_ARCH_SUFFIX="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;;
esac

# Install k9s from latest GitHub release (~40MB vs 154MB from Nix)
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)
echo "Installing k9s ${K9S_VERSION}"
curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_linux_${ARCH_SUFFIX}.tar.gz" -o /tmp/tool-cache/k9s.tar.gz
tar -xzf /tmp/tool-cache/k9s.tar.gz -C /tmp/tool-cache/
mv /tmp/tool-cache/k9s /usr/local/bin/k9s
chmod +x /usr/local/bin/k9s

# Install helm from latest GitHub release (~50MB vs larger Nix version)
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)
echo "Installing helm ${HELM_VERSION}"
curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH_SUFFIX}.tar.gz" -o /tmp/tool-cache/helm.tar.gz
tar -xzf /tmp/tool-cache/helm.tar.gz -C /tmp/tool-cache/
mv /tmp/tool-cache/linux-${ARCH_SUFFIX}/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

# Install argocd CLI from latest GitHub release (~80MB vs 158MB from Nix)
ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r .tag_name)
echo "Installing argocd ${ARGOCD_VERSION}"
curl -sSL -o /tmp/tool-cache/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH_SUFFIX}"
mv /tmp/tool-cache/argocd /usr/local/bin/argocd
chmod +x /usr/local/bin/argocd

# Install AWS CLI v2 (official installer, smaller than Python wheel)
echo "Installing AWS CLI v2"
if [ "${ARCH}" = "x86_64" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/tool-cache/awscliv2.zip
elif [ "${ARCH}" = "aarch64" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o /tmp/tool-cache/awscliv2.zip
fi
unzip -qo /tmp/tool-cache/awscliv2.zip -d /tmp/tool-cache/
/tmp/tool-cache/aws/install

# Install Azure CLI (official script, smaller than full Python package)
echo "Installing Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install p6m-cli from latest GitHub release
P6M_VERSION=$(curl -s https://api.github.com/repos/p6m-dev/p6m-cli/releases/latest | jq -r .tag_name)
echo "Installing p6m-cli ${P6M_VERSION}"
curl -ssL "https://github.com/p6m-dev/p6m-cli/releases/download/${P6M_VERSION}/p6m-${P6M_VERSION}-linux-${ALT_ARCH_SUFFIX}.tar.gz" -o /tmp/tool-cache/p6m.tar.gz
tar -xzf /tmp/tool-cache/p6m.tar.gz -C /tmp/tool-cache/
mv /tmp/tool-cache/p6m-${P6M_VERSION}-linux-${ALT_ARCH_SUFFIX}/p6m /usr/local/bin/p6m
chmod +x /usr/local/bin/p6m

# Install archetect from latest GitHub release
ARCHETECT_VERSION=$(curl -s https://api.github.com/repos/archetect/archetect/releases/latest | jq -r .tag_name)
echo "Installing archetect ${ARCHETECT_VERSION}"
curl -ssL "https://github.com/archetect/archetect/releases/download/${ARCHETECT_VERSION}/archetect-${ARCHETECT_VERSION}-linux-${ALT_ARCH_SUFFIX}.tar.gz" -o /tmp/tool-cache/archetect.tar.gz
tar -xzf /tmp/tool-cache/archetect.tar.gz -C /tmp/tool-cache/
mv /tmp/tool-cache/archetect-${ARCHETECT_VERSION}-linux-${ALT_ARCH_SUFFIX}/archetect /usr/local/bin/archetect
chmod +x /usr/local/bin/archetect