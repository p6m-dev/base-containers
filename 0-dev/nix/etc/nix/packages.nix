{ pkgs ? import <nixpkgs> { } }:

with pkgs;
[
  # Build Essential
  gnumake
  binutils
  glibc
  coreutils
  autoconf
  automake
  libtool

  # Development Tools
  code-server

  # Utilities
  fzf
  yq-go
  jq

  # Kubernetes - Keep lightweight/essential tools in Nix
  kubectl
  kustomize
  kubectx
  stern

  # Cloud
  gh
  k9s
  helm
  argocd
  awscli2
  azure-cli-bin
]
