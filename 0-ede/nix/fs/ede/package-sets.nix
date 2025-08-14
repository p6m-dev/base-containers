{ pkgs }: {
  # Replace this file with your own package set derivation if needed
  some-toolchain = {
    packages = with pkgs; [ some-package ];
    env = {
      SOME_ENV_VAR = "default-value";
    };
  };
}
