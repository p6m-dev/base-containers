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

  # Auto-detection based on project files (current dir and one level deep)
  detectPackages =
    let
      fileExists = file: builtins.pathExists (./. + "/${file}");
      
      # Get all subdirectories and check for files
      findInSubdirs = file:
        let
          subdirs = builtins.attrNames (builtins.readDir ./.);
          checkSubdir = subdir: 
            let path = ./. + "/${subdir}";
            in builtins.pathExists path && 
               builtins.readDir path ? ${file};
        in
        builtins.any checkSubdir subdirs;
      
      # Check current directory or any subdirectory
      hasFile = file: fileExists file || findInSubdirs file;
      
      detected = [ ]
        ++ (if hasFile "package.json" then packageSets.nodejs else [ ])
        ++ (if hasFile "requirements.txt" || hasFile "pyproject.toml" then packageSets.python else [ ])
        ++ (if hasFile "Cargo.toml" then packageSets.rust else [ ])
        ++ (if hasFile "go.mod" then packageSets.go else [ ])
        ++ (if hasFile "pom.xml" || hasFile "build.gradle" then packageSets.java else [ ])
        ++ (if hasFile "Dockerfile" then packageSets.docker else [ ])
        ++ (if hasFile "main.tf" then packageSets.terraform else [ ]);
    in
    detected;

  # Detection messages for shell hook
  detectionMessages = 
    let
      fileExists = file: builtins.pathExists (./. + "/${file}");
      
      findFileInSubdirs = file:
        let
          subdirs = builtins.attrNames (builtins.readDir ./.);
          findSubdir = subdir: 
            let path = ./. + "/${subdir}";
            in if builtins.pathExists path && builtins.readDir path ? ${file}
               then subdir
               else null;
          found = builtins.filter (x: x != null) (map findSubdir subdirs);
        in
        if builtins.length found > 0 then builtins.head found else null;
      
      getPath = file:
        if fileExists file then "."
        else let subdir = findFileInSubdirs file;
             in if subdir != null then subdir else null;
      
      messages = []
        ++ (let path = getPath "package.json"; in if path != null then ["Node.js project detected at ${path}"] else [])
        ++ (let path = getPath "requirements.txt"; in if path != null then ["Python project detected at ${path}"] else [])
        ++ (let path = getPath "pyproject.toml"; in if path != null then ["Python project detected at ${path}"] else [])
        ++ (let path = getPath "Cargo.toml"; in if path != null then ["Rust project detected at ${path}"] else [])
        ++ (let path = getPath "go.mod"; in if path != null then ["Go project detected at ${path}"] else [])
        ++ (let path = getPath "pom.xml"; in if path != null then ["Java project detected at ${path}"] else [])
        ++ (let path = getPath "build.gradle"; in if path != null then ["Java project detected at ${path}"] else [])
        ++ (let path = getPath "Dockerfile"; in if path != null then ["Docker project detected at ${path}"] else [])
        ++ (let path = getPath "main.tf"; in if path != null then ["Terraform project detected at ${path}"] else []);
    in
    messages;

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
    
    ${pkgs.lib.concatStringsSep "\n    " (map (msg: "echo \"🔍 ${msg}\"") detectionMessages)}
    
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
