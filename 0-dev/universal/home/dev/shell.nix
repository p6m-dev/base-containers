let
  pkgs = import <nixpkgs> { };
in
with pkgs; import /home/default.nix {
  inherit pkgs;
  packages = [ ];
}
