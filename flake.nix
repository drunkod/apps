{
  description = "Nix Flake for a Node.js application with pnpm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or a specific version
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.default = pkgs.mkShell {
      buildInputs = [
        pkgs.nodejs
        pkgs.pnpm
        pkgs.gcc
        # pkgs.make
        pkgs.python3
        # pkgs.libc6
        pkgs.git
        pkgs.gh
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
          # Use the current directory as the source
          installPhase = ''
            mkdir -p $out/opt/app
            cp -r ./packages $out/opt/app/packages
            cp -r ./patches $out/opt/app/patches
            cp package*.json $out/opt/app/
            cp packages/eslint-config/package*.json $out/opt/app/packages/eslint-config/
            cp packages/eslint-rules/package*.json $out/opt/app/packages/eslint-rules/
            cp packages/extension/package*.json $out/opt/app/packages/extension/
            cp packages/prettier-config/package*.json $out/opt/app/packages/prettier-config/
            cp packages/shared/package*.json $out/opt/app/packages/shared/
            cp packages/webapp/package*.json $out/opt/app/packages/webapp/
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