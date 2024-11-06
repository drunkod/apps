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

    node = pkgs.mkShell {
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
        echo "node `${pkgs.nodejs}/bin/node --version`"
        echo "update"

        # Create app directory and set working directory
              mkdir -p app
              cd app

              # Copy package.json files
              for file in package*.json; do
                if [ -f "$file" ]; then
                  cp "$file" .
                fi
              done

              # Create and copy package.json files for each package
              mkdir -p packages/{eslint-config,eslint-rules,extension,prettier-config,shared,webapp}
              
              for dir in eslint-config eslint-rules extension prettier-config shared webapp; do
                if [ -f "packages/$dir/package.json" ]; then
                  cp "packages/$dir/package"*.json "./packages/$dir/"
                fi
              done

              # Copy patches directory if it exists
              if [ -d "patches" ]; then
                cp -r patches /opt/app/
              fi

              echo "Development environment setup complete"
      '';
    };    
    };
  };
}