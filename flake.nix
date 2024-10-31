{
  description = "Nix Flake for a Node.js application with pnpm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or a specific version
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: {
    packages.default = pkgs.mkShell {
      buildInputs = [
        nixpkgs.nodejs
        nixpkgs.pnpm
        nixpkgs.gcc
        nixpkgs.make
        nixpkgs.python3
        nixpkgs.libc6
      ];

      shellHook = ''
        echo "Welcome to the Nix shell for the Node.js application!"
        echo "Run 'pnpm install' to install dependencies."
        echo "Run 'npm run dev' to start the application."
      '';
    };

    # Optionally, you can create a Docker image
    dockerImage = pkgs.dockerTools.buildImage {
      name = "my-node-app";
      contents = [
        (pkgs.nodejs.override {
          package = pkgs.nodejs;
        })
        (pkgs.pnpm.override {
          package = pkgs.pnpm;
        })
        (pkgs.runCommand "app" {
          buildInputs = [
            pkgs.nodejs
            pkgs.pnpm
            pkgs.gcc
            pkgs.make
            pkgs.python3
            pkgs.libc6
          ];
          # Copy the application files
          src = ./.;
          installPhase = ''
            mkdir -p $out/opt/app
            cp -r ${src}/packages $out/opt/app/packages
            cp -r ${src}/patches $out/opt/app/patches
            cp ${src}/package*.json $out/opt/app/
            cp ${src}/packages/eslint-config/package*.json $out/opt/app/packages/eslint-config/
            cp ${src}/packages/eslint-rules/package*.json $out/opt/app/packages/eslint-rules/
            cp ${src}/packages/extension/package*.json $out/opt/app/packages/extension/
            cp ${src}/packages/prettier-config/package*.json $out/opt/app/packages/prettier-config/
            cp ${src}/packages/shared/package*.json $out/opt/app/packages/shared/
            cp ${src}/packages/webapp/package*.json $out/opt/app/packages/webapp/
          '';
        })
      ];
      config = {
        Cmd = [ "pnpm" "install" ];
        WorkingDir = "/opt/app/packages/webapp";
        Expose = [ "3000" ]; # Change this if your app runs on a different port
      };
    };
  });
}
