{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

    outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        db-location = "$PWD/.database";
        db-name = "mydb";
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            openssl
            pkg-config
            eza
            fd

            pre-commit
            rust-bin.stable.latest.default
            diesel-cli

            # Database libraries
            postgresql
          ];

          installPhase = ''
            
          '';

          shellHook = ''
            alias ls=eza
            alias find=fd
            
            # manage postgres
            db=${db-location}/${db-name}
            mkdir -p ${db-location}/tmp
            
            if [[ ! -d "$db" ]]; then
              initdb -D $db
            fi

            pg_ctl -D $db -l ${db-location}/logfile -o "--unix_socket_directories='${db-location}/tmp'" start
            trap "pg_ctl -D $db stop" EXIT

            # clear
            export PS1="\n\[\033[1;32m\][rust-env]\[\033[0m\]$ ";
          '';
        };
      }
    );
}