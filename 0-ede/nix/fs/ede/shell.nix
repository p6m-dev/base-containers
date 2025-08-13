# Can be called as flake outputs or as mkShell
{ packages ? [ ], system ? builtins.currentSystem }:

let
  packageSet = import ./packages.nix { inherit system; };
  pkgs = packageSet.pkgs;
  homePkgs = packageSet.packages;

  # Helper function to get packages from environment variable (disabled in pure mode)
  envPackages = [ ];
  packageSets = import ./package-sets.nix { inherit pkgs; };

  # Helper function to get package set by name
  getPackageSet = name:
    if builtins.hasAttr name packageSets
    then builtins.getAttr name packageSets
    else [ ];

  # Auto-detection based on project files (current dir and one level deep)
  detection =
    let
      # Use PWD from native environment, fall back to shell.nix location
      currentPwd = builtins.getEnv "PWD";
      workingDir = if currentPwd != "" then currentPwd else toString ./.;

      # Safe file existence check that handles permission errors
      safePathExists = path:
        builtins.tryEval (builtins.pathExists path) // { value = false; };

      # Safe directory reading that handles permission errors
      safeReadDir = path:
        let result = builtins.tryEval (builtins.readDir path);
        in if result.success then result.value else { };

      # Safe directory accessibility check
      safeDirExists = path:
        let result = builtins.tryEval (builtins.pathExists path);
        in if result.success then result.value else false;

      # Safe file existence check that ignores permission errors
      # First checks if the parent directory is accessible
      safeFileExists = path:
        let
          # Extract parent directory from path
          parentDir = builtins.dirOf path;
          # Check if parent directory is accessible first
          parentAccessible = safeDirExists parentDir;
          # Only try to check file if parent directory is accessible
          result =
            if parentAccessible then
              builtins.tryEval (builtins.pathExists path)
            else
              { success = true; value = false; };
        in
        if result.success then result.value else false;

      # Find which directory contains the file (current or subdirectory)
      findFileLocation = file:
        if currentPwd != "" then
        # Check current directory first
          if safeFileExists (currentPwd + "/${file}") then "."
          else
          # Check subdirectories (1 level deep)
            let
              entries = if safeDirExists currentPwd then safeReadDir currentPwd else { };
              subdirs = builtins.attrNames (pkgs.lib.filterAttrs (name: type: type == "directory") entries);
              findSubdir = subdir:
                let subdirPath = currentPwd + "/${subdir}";
                in
                if safeDirExists subdirPath && safeFileExists (subdirPath + "/${file}")
                then subdir
                else null;
              found = builtins.filter (x: x != null) (map findSubdir subdirs);
            in
            if builtins.length found > 0 then builtins.head found else null
        else
        # Fall back to evaluation context
          if (safePathExists (./. + "/${file}")).value then "." else null;

      # Check if file exists (wrapper around findFileLocation)
      fileExists = file: findFileLocation file != null;

      # Get path where file is located (same as findFileLocation)
      getPath = file: findFileLocation file;

      detections = [
        { file = "package.json"; packages = packageSets.nodejs; name = "Node.js"; }
        { file = "requirements.txt"; packages = packageSets.python; name = "Python"; }
        { file = "pyproject.toml"; packages = packageSets.python; name = "Python"; }
        { file = "Cargo.toml"; packages = packageSets.rust; name = "Rust"; }
        { file = "go.mod"; packages = packageSets.go; name = "Go"; }
        { file = "pom.xml"; packages = packageSets.java; name = "Java"; }
        { file = "build.gradle"; packages = packageSets.java; name = "Java"; }
        { file = "Dockerfile"; packages = packageSets.docker; name = "Docker"; }
      ];

      results = map
        (d:
          let
            path = getPath d.file;
            exists = fileExists d.file;
          in
          if path != null then {
            packages = d.packages;
            message = "${d.name} project detected at ${path}";
          } else null
        )
        detections;

      validResults = builtins.filter (r: r != null) results;
    in
    {
      packages = pkgs.lib.concatLists (map (r: r.packages) validResults);
      messages = map (r: r.message) validResults;
    };

  # Combine all package sources
  extraPkgs = packages ++ envPackages ++ detection.packages;
  extraPkgsCount = builtins.length extraPkgs;
  allPkgs = pkgs.lib.unique (homePkgs ++ extraPkgs);

  # Shell derivation
  shell = pkgs.mkShell {
    buildInputs = allPkgs;

    shellHook = ''
      export OPENSSL_DIR="${pkgs.openssl.dev}"
      export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
      export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
      export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib:$LD_LIBRARY_PATH"

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
  };

  # Flake outputs function
  flakeOutputs =
    let
      systems = packageSet.systems;
      forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
    in
    {
      devShells = forAllSystems (system: {
        default =
          let packageSet = import ./packages.nix { inherit system; };
          in packageSet.pkgs.mkShell {
            buildInputs = packageSet.packages;
            shellHook = shell.shellHook;
          };
      });
      packages = forAllSystems (system: {
        default =
          let packageSet = import ./packages.nix { inherit system; };
          in packageSet.pkgs.buildEnv {
            name = "ede-packages";
            paths = packageSet.packages;
          };
      });
    };

  # Flake outputs helpers
  systems = packageSet.systems;
  forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
in

# Export both shell and flake outputs
{
  inherit shell;

  devShells = forAllSystems (system: {
    default = (import ./shell.nix { inherit system; }).shell;
  });
  packages = forAllSystems (system: {
    default =
      let ps = import ./packages.nix { inherit system; };
      in ps.pkgs.buildEnv {
        name = "ede-packages";
        paths = ps.packages;
      };
  });
}
