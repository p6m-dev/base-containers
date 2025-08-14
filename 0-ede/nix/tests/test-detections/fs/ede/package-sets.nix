{ pkgs }: {
  # Replace this file with your own package set derivation if needed
  rust = {
    packages = with pkgs.rustPackages; [ rustc cargo clippy rustfmt rustPlatform.rustLibSrc ];
    env = {
      RUST_SRC_PATH = "${pkgs.rustPackages.rustPlatform.rustLibSrc}";
    };
  };
}
