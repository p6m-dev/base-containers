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
  detection = 
    let
      fileExists = file: builtins.pathExists (./. + "/${file}");
      
      findFileInSubdirs = file:
        let
          currentDirExists = builtins.pathExists ./.;
          entries = if currentDirExists then builtins.readDir ./. else {};
          subdirs = builtins.attrNames (pkgs.lib.filterAttrs (name: type: type == "directory") entries);
          findSubdir = subdir: 
            let 
              path = ./. + "/${subdir}";
              subdirExists = builtins.pathExists path;
            in 
            if subdirExists && builtins.pathExists (path + "/${file}")
            then subdir
            else null;
          found = builtins.filter (x: x != null) (map findSubdir subdirs);
        in
        if builtins.length found > 0 then builtins.head found else null;
      
      getPath = file:
        if fileExists file then "."
        else let subdir = findFileInSubdirs file;
             in if subdir != null then subdir else null;
      
      detections = [
        { file = "package.json"; packages = packageSets.nodejs; name = "Node.js"; }
        { file = "requirements.txt"; packages = packageSets.python; name = "Python"; }
        { file = "pyproject.toml"; packages = packageSets.python; name = "Python"; }
        { file = "Cargo.toml"; packages = packageSets.rust; name = "Rust"; }
        { file = "go.mod"; packages = packageSets.go; name = "Go"; }
        { file = "pom.xml"; packages = packageSets.java; name = "Java"; }
        { file = "build.gradle"; packages = packageSets.java; name = "Java"; }
        { file = "Dockerfile"; packages = packageSets.docker; name = "Docker"; }
        { file = "main.tf"; packages = packageSets.terraform; name = "Terraform"; }
      ];
      
      results = map (d: 
        let path = getPath d.file;
        in if path != null then { 
          packages = d.packages; 
          message = "${d.name} project detected at ${path}";
        } else null
      ) detections;
      
      validResults = builtins.filter (r: r != null) results;
    in
    {
      packages = pkgs.lib.concatLists (map (r: r.packages) validResults);
      messages = map (r: r.message) validResults;
    };

  # Combine all package sources
  extraPkgs = packages ++ envPackages ++ detection.packages;
  extraPkgsCount = builtins.length extraPkgs;
  allPkgs = homePkgs ++ extraPkgs;
in

pkgs.mkShell {
  buildInputs = allPkgs;

  shellHook = ''
    echo "🚀 Nix development environment loaded"
    echo "📦 Base packages: ${toString (builtins.length homePkgs)}"
    
    ${pkgs.lib.concatStringsSep "\n    " (map (msg: "echo \"🔍 ${msg}\"") detection.messages)}
    
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
