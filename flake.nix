{
  description = "Webapp development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in pkgs.mkShell {
      packages = with pkgs; [
        nodejs_20
        # nodePackages.pnpm
        #(yarn.override { nodejs = nodejs_18; })
        # Add nvm if needed
        # nvm
      ];

      # Environment variables
      shellHook = ''
        export NEXT_PUBLIC_API_URL="http://localhost:5000"
        export NEXT_PUBLIC_SUBS_URL="ws://localhost:5000/graphql"
        export NEXT_PUBLIC_DOMAIN="localhost"
        export NEXT_PUBLIC_WEBAPP_URL="/"
        export NEXT_PUBLIC_AUTH_URL="http://localhost"
        export NEXT_PUBLIC_HEIMDALL_URL="http://localhost"

        echo "node `${pkgs.nodejs}/bin/node --version`"
        echo "update"
        # npm config set registry http://registry.npmjs.org/ 
        npm config set strict-ssl=false
        # Initialize project
        if [ ! -f "pnpm-lock.yaml" ]; then
          echo "Installing pnpm and project dependencies..."
          npm i -g pnpm@8.15.7
          # npm config set strict-ssl=false
          pnpm install
        fi

        # Optional: Auto-cd into webapp directory
        if [ -d "packages/webapp" ]; then
          cd packages/webapp
          echo "Changed directory to packages/webapp"
        fi

        # You can uncomment this if you want the dev server to start automatically
        # npm run dev
      '';
    };
  };
}