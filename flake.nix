{
  description = "Webapp development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    devShells."${system}" = {
      default = pkgs.mkShell {
      packages = with pkgs; [
        git
        nodejs_20
        pnpm_8
        # nodePackages.pnpm
        #(yarn.override { nodejs = nodejs_18; })
        # Add nvm if needed
        # nvm
      ];

      # Environment variables
      shellHook = ''
        git clone https://github.com/drunkod/apps.git .
        
        export NEXT_PUBLIC_API_URL="http://localhost:5000"
        export NEXT_PUBLIC_SUBS_URL="ws://localhost:5000/graphql"
        export NEXT_PUBLIC_DOMAIN="localhost"
        export NEXT_PUBLIC_WEBAPP_URL="/"
        export NEXT_PUBLIC_AUTH_URL="http://localhost"
        export NEXT_PUBLIC_HEIMDALL_URL="http://localhost"

        echo "node `${pkgs.nodejs}/bin/node --version`"
        echo "update"

        # npm config set registry http://registry.npmjs.org/ 
        # npm config set strict-ssl=false

        # Optional: Auto-cd into webapp directory
        if [ -d "packages/webapp" ]; then
          cd packages/webapp
          echo "Changed directory to packages/webapp"
        fi

        # Initialize project
        if [ ! -f "pnpm-lock.yaml" ]; then
          echo "Installing pnpm and project dependencies..."
          # npm i -g pnpm@8.15.7
          # npm config set strict-ssl=false
          pnpm install
        fi

        # You can uncomment this if you want the dev server to start automatically
        # npm run dev
      '';
    };

    docker = pkgs.mkShell {
      packages = with pkgs; [
        git
        nodejs_20
        pnpm_8
        # nodePackages.pnpm
        #(yarn.override { nodejs = nodejs_18; })
        # Add nvm if needed
        # nvm
      ];

      # Environment variables
      shellHook = ''

        # Create working directory structure
        export PROJECT_ROOT="$PWD"
        WORK_DIR="$PWD/app"
        if [ ! -d "$WORK_DIR" ]; then
            mkdir -p "$WORK_DIR"
            chmod 755 "$WORK_DIR"
        fi
        PACK_DIR="$WORK_DIR/packages"
        if [ ! -d "$PACK_DIR" ]; then
            mkdir -p "$PACK_DIR"
            chmod 755 "$PACK_DIR"
        fi

        # Copy package.json files
        cp package*.json "$WORK_DIR/"
        cp pnpm-*.yaml "$WORK_DIR/"

        # Create directories for each package
        mkdir -p "$PACK_DIR/eslint-config"
        mkdir -p "$PACK_DIR/eslint-rules"
        mkdir -p "$PACK_DIR/extension"
        mkdir -p "$PACK_DIR/prettier-config"
        mkdir -p "$PACK_DIR/shared"
        mkdir -p "$PACK_DIR/webapp"

        # Copy package.json files for each package
        cp packages/eslint-config/package*.json "$PACK_DIR/eslint-config/"
        cp packages/eslint-rules/package*.json "$PACK_DIR/eslint-rules/"
        cp packages/extension/package*.json "$PACK_DIR/extension/"
        cp packages/prettier-config/package*.json "$PACK_DIR/prettier-config/"
        cp packages/shared/package*.json "$PACK_DIR/shared/"
        cp packages/webapp/package*.json "$PACK_DIR/webapp/"

        # Create and copy patches directory
        mkdir -p "$WORK_DIR/patches"
        cp -r patches/* "$WORK_DIR/patches/"

        cd "$WORK_DIR"

        # Install project dependencies
        pnpm install

        # Copy the contents of the original packages directory to the new packages directory
        cp -r "$PROJECT_ROOT/packages/"* "$PACK_DIR/"

        # Change to the webapp directory
        cd "$PACK_DIR/webapp"

        # Install webapp dependencies
        pnpm install

        # Verify next.js installation
        if [ ! -d "node_modules/next" ]; then
          echo "Installing next.js..."
          pnpm add next@latest
        fi        

        echo "node `${pkgs.nodejs}/bin/node --version`"
        echo "update"

        echo "Development environment setup complete"
      '';
    };    
    };
  };
}