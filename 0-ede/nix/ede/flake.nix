{
  description = "Reuse local default.nix for flakes";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      mkShell = system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        };
      mkAttrs = f:
        builtins.listToAttrs (map
          (system:
            {
              name = system;
              value = f system;
            }
          )
          systems);
    in
    {
      # for `nix develop`do
      devShells = mkAttrs mkShell;

      # for `nix shell`
      packages = mkAttrs (system: { default = mkShell system; });
    };
}
