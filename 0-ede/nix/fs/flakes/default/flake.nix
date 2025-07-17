{
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { nixpkgs, ... }:
    import /ede/default.nix { inherit nixpkgs; };
}
