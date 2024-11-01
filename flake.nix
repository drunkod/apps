{
  description = "Node.js development environment with pnpm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js and development tools
            nodejs_20
            python3
            gcc
            gnumake

            # Package manager
            nodePackages.pnpm

            # Additional dependencies
            glibc
            curl # for healthchecks
          ];

          shellHook = ''
            # Create necessary directories
            mkdir -p /tmp/app
            
            # Set environment variables
            export PATH="$PWD/node_modules/.bin:$PATH"
          '';
        };

        # Optional: Define a package if you want to build the application
        packages.default = pkgs.stdenv.mkDerivation {
          name = "webapp";
          version = "1.0.0";

          src = ./.;

          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.pnpm
            python3
            gcc
            gnumake
          ];

          buildPhase = ''
            # Copy package.json files
            mkdir -p $out/tmp/app
            cp package*.json $out/tmp/app/
            
            mkdir -p $out/tmp/app/packages/{eslint-config,eslint-rules,extension,prettier-config,shared,webapp}
            cp packages/eslint-config/package*.json $out/tmp/app/packages/eslint-config/
            cp packages/eslint-rules/package*.json $out/tmp/app/packages/eslint-rules/
            cp packages/extension/package*.json $out/tmp/app/packages/extension/
            cp packages/prettier-config/package*.json $out/tmp/app/packages/prettier-config/
            cp packages/shared/package*.json $out/tmp/app/packages/shared/
            cp packages/webapp/package*.json $out/tmp/app/packages/webapp/

            # Copy patches
            cp -r patches $out/tmp/app/

            # Install dependencies
            cd $out/tmp/app
            pnpm install

            # Copy source files
            cp -r packages $out/tmp/app/
          '';

          installPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/start-webapp <<EOF
            #!/bin/sh
            cd $out/tmp/app/packages/webapp
            exec pnpm start
            EOF
            chmod +x $out/bin/start-webapp
          '';

          meta = {
            description = "Web application with pnpm workspace";
            platforms = pkgs.lib.platforms.linux;
          };
        };
      });
}

