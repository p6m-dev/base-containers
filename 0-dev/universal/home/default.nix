{ pkgs ? import <nixpkgs> { }, packages ? [ ] }:

let
  homePkgs = import /home/packages.nix { inherit pkgs; };
  extraPkgs = packages;
  allPkgs = homePkgs ++ extraPkgs;
in

pkgs.mkShell {
  buildInputs = allPkgs;

  shellHook = ''
        echo "Entering shell with: \
    ${pkgs.lib.concatStringsSep " " (map (p: p.name) (allPkgs))}"
  '';
}
