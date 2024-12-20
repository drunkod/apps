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
        # Development shell configuration
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bashInteractive
            nodejs_20
            python3
            gcc
            gnumake
            nodePackages.pnpm
            glibc
            curl
          ];

      shellHook = ''
        echo "Welcome to the Nix shell for the Node.js application!"
        echo "Run 'pnpm install' to install dependencies."
        echo "Run 'npm run dev' to start the application."

        # Prompt for Git configuration
        read -p "Do you want to set up Git configuration? (y/n): " setup_git
        if [ "$setup_git" = "y" ]; then
          read -p "Enter your name: " git_name
          read -p "Enter your email: " git_email
          git config --global user.name "$git_name"
          git config --global user.email "$git_email"
          echo "Git configuration set for user: $git_name <$git_email>"
        else
          echo "Skipping Git configuration."
        fi
                    # Configure pnpm to ignore SSL verification
            pnpm config set strict-ssl false
      '';
    };

        # Package definition for building the application
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
            # Create temporary application directory
            mkdir -p $out/tmp/app
            
            # Copy package.json files
            cp package*.json $out/tmp/app/
            
            # Copy package-specific JSON files
            for pkg in eslint-config eslint-rules extension prettier-config shared webapp; do
              mkdir -p $out/tmp/app/packages/$pkg
              cp packages/$pkg/package*.json $out/tmp/app/packages/$pkg/
            done

            # Copy patches
            cp -r patches $out/tmp/app/

            # Install dependencies
            cd $out/tmp/app
            pnpm config set strict-ssl false  # Configure pnpm to ignore SSL verification
            pnpm install

            # Copy source files
            cp -r packages $out/tmp/app/
          '';

          installPhase = ''
            # Create executable script to start the web application
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
