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

  # Kubernetes - Keep lightweight/essential tools in Nix
  kubectl
  kustomize
  kubectx
  stern

  # Cloud - Keep lightweight tools in Nix
  gh
  
  # Heavy tools moved to direct downloads in Dockerfile:
  # k9s, helm, argocd, awscli2, azure-cli
]
