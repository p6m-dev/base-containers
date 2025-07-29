{ system ? builtins.currentSystem }:

let
  nixpkgsUrl =
    let envUrl = builtins.getEnv "NIXPKGS_URL";
    in if envUrl != "" then envUrl else "github:NixOS/nixpkgs/nixos-unstable";

  systems = [ "x86_64-linux" "aarch64-linux" ];
  forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);

  nixpkgs = builtins.getFlake nixpkgsUrl;
  pkgs = nixpkgs.legacyPackages.${system};
in

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
  openssl
  pkg-config

  # EDE Tools
  # coder

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
  # (stdenv.mkDerivation rec {
  #   pname = "azure-cli";
  #   version = "2.75.0";

  #   src = fetchurl {
  #     url = "https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_${version}-1~noble_${
  #       if stdenv.isAarch64 then "arm64" else "amd64"
  #     }.deb";
  #     sha256 =
  #       if stdenv.isAarch64 then
  #         "sha256-0yXbOQWW71cKcH0XXXVKijIOQ0/R8RZfiRNBhMIqDyg=" else
  #         "sha256-EvOm8jZsfsyHyF18QNjCB8psq1bCK/loucaF6TzosWw=";
  #   };

  #   nativeBuildInputs = [ dpkg ];

  #   dontUnpack = true;

  #   installPhase = ''
  #     dpkg -x $src tmp
  #     mv tmp/etc $out/
  #     mv tmp/opt $out/
  #     mv tmp/usr $out/
  #   '';
  # })
]
