{ pkgs ? import <nixpkgs> { }, packages ? [ ] }:

let
  homePkgs = import /etc/nix/packages.nix { inherit pkgs; };
  extraPkgs = packages;
  extraPkgsCount = builtins.length extraPkgs;
  allPkgs = homePkgs ++ extraPkgs;
in

pkgs.mkShell {
  buildInputs = allPkgs;

  shellHook = ''
    if [ ${toString extraPkgsCount} -eq 0 ]; then
      echo "Entering shell with no extra packages installed."
    else
      echo "Entering shell with ${toString extraPkgsCount} additional package(s) installed:"
      for pkg in ${pkgs.lib.concatStringsSep " " (map (p: p.name) extraPkgs)}; do
        printf "\t%s\n" "$pkg"
      done
    fi
  '';
}
