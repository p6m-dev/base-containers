{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Utilities
  fzf
  gh
  yq-go

  # Language runtimes
  dotnet-sdk
  nodejs
  python3
  ruby
  openjdk
  go
  rustc

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
  kind
  minikube
  stern
  argocd
  flux

  # Cloud tools
  awscli2
  azure-cli
]