{
  description = "Apache pulsar standalone development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let 
      pkgs = import nixpkgs { inherit system; };
      
      version = "3.1.0";
      sha256 = "02x0hr1jvc2siw87yr3lwg9abbfxgbvalvj3ghg5g5jhgybxjnj8";

    in rec {
      packages = {
        pulsar = pkgs.stdenv.mkDerivation rec {   
          name = "pulsar";
          src = fetchTarball {
            url = "https://archive.apache.org/dist/pulsar/pulsar-${version}/pache-pulsar-${version}-bin.tar.gz";
            sha256 = sha256;
          };
        
        buildInputs = [
          pkgs.makeWrapper
          pkgs.jre_headless
          pkgs.util-linux
          pkgs.zlib
        ];

        runtimeDependencies = [
          pkgs.zlib
        ];

        installPhase = ''
          mkdir -p $out
          cp -R bin conf instances lib trino $out

          chmod +x $out/bin/*

          wrapProgram $out/bin/pulsar \
            --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.util-linux pkgs.coreutils pkgs.gnugrep ]}" \
            --set JAVA_HOME "${pkgs.jre_headless}"
        '';

        };
      };
      
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.bashInteractive
          packages.pulsar
        ];
      };

      defaultPackage = packages.pulsar;
    });
}