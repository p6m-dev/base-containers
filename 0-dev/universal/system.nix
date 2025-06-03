{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Utilities
  fzf
  gh
  yq-go

  # Build tools
  gnumake
  cmake
  pkg-config

  # Kubernetes tools
  kubectl
  k9s
  helm
  kustomize
  kubectx
  stern
  argocd

  # Cloud tools
  awscli2
  azure-cli
]