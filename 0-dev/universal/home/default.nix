let
  pkgs     = import <nixpkgs> {};
  homePkgs = import /home/packages.nix { inherit pkgs; };
in

pkgs.mkShell {
  buildInputs = homePkgs;

  shellHook = ''
    echo "Entering dev shell with: ${pkgs.lib.concatStringsSep " " (map (p: p.name) homePkgs)}"
  '';
}
