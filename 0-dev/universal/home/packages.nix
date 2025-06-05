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

  # Utilities
  fzf
  yq-go

  # Kubernetes
  kubectl
  k9s
  helm
  kustomize
  kubectx
  stern
  argocd

  # Cloud
  gh
  awscli2
  azure-cli
]
