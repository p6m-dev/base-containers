{ pkgs ? import <nixpkgs> {} }:

with pkgs; [
  # Utilities
  yq-go
  jq
  curl
  git
  fzf

  # Language runtimes - LTS versions
  dotnet-sdk_8    # .NET 8 LTS
  nodejs_22       # Node.js 22 LTS
  python312       # Python 3.12 LTS
  ruby_3_3        # Ruby 3.3 LTS
  openjdk21       # Java 21 LTS
  go_1_23         # Go 1.23 LTS
  rustc           # Rust stable

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
]