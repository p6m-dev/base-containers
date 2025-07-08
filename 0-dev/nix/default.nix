{ pkgs ? import <nixpkgs> { }, packages ? [ ] }:

let
  homePkgs = import /etc/nix/packages.nix { inherit pkgs; };

  # Helper function to get packages from environment variable
  envPackages =
    let
      envVar = builtins.getEnv "EXTRA_PACKAGES";
      packageNames = if envVar != "" then pkgs.lib.splitString "," envVar else [ ];
    in
    map (name: pkgs.lib.getAttr (pkgs.lib.trim name) pkgs) packageNames;

  # Predefined package sets for common development scenarios
  packageSets = {
    nodejs = with pkgs; [ nodejs_22 yarn nodePackages.npm nodePackages.typescript nodePackages.pnpm ];
    python = with pkgs; [ python3 python3Packages.pip python3Packages.virtualenv ];
    rust = with pkgs; [ rustc cargo rustfmt clippy ];
    go = with pkgs; [ go gopls ];
    java = with pkgs; [ openjdk17 maven gradle ];
    docker = with pkgs; [ docker docker-compose ];
    terraform = with pkgs; [ terraform terraform-ls ];
  };

  # Helper function to get package set by name
  getPackageSet = name:
    if builtins.hasAttr name packageSets
    then builtins.getAttr name packageSets
    else [ ];

  # Auto-detection based on project files
  detectPackages =
    let
      fileExists = file: builtins.pathExists (./. + "/${file}");
      detected = [ ]
        ++ (if fileExists "package.json" then packageSets.nodejs else [ ])
        ++ (if fileExists "requirements.txt" || fileExists "pyproject.toml" then packageSets.python else [ ])
        ++ (if fileExists "Cargo.toml" then packageSets.rust else [ ])
        ++ (if fileExists "go.mod" then packageSets.go else [ ])
        ++ (if fileExists "pom.xml" || fileExists "build.gradle" then packageSets.java else [ ])
        ++ (if fileExists "Dockerfile" then packageSets.docker else [ ])
        ++ (if fileExists "main.tf" then packageSets.terraform else [ ]);
    in
    detected;

  # Combine all package sources
  extraPkgs = packages ++ envPackages ++ detectPackages;
  extraPkgsCount = builtins.length extraPkgs;
  allPkgs = homePkgs ++ extraPkgs;
in

pkgs.mkShell {
  buildInputs = allPkgs;

  shellHook = ''
    echo "🚀 Nix development environment loaded"
    echo "📦 Base packages: ${toString (builtins.length homePkgs)}"
    
    if [ ${toString extraPkgsCount} -eq 0 ]; then
      echo "➕ No additional packages loaded"
    else
      echo "➕ Additional packages (${toString extraPkgsCount}):"
      for pkg in ${pkgs.lib.concatStringsSep " " (map (p: p.name or p.pname or "unknown") extraPkgs)}; do
        printf "   • %s\n" "$pkg"
      done
    fi
  '';
}
