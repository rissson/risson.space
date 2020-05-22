let
  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-unstable-risson.space";
    url = "https://github.com/nixos/nixpkgs/archive/0f5ce2fac0c726036ca69a5524c59a49e2973dd4.tar.gz";
    sha256 = "0nkk492aa7pr0d30vv1aw192wc16wpa1j02925pldc09s9m9i0r3";
  };
in

{ pkgs ? import nixpkgs { }, theme ? "slick" }:

with pkgs;
with lib;

let

  hugoConfig = builtins.removeAttrs (
    pkgs.callPackage ./config { inherit pkgs theme; prod = false; }
  ).config [ "_module" ];

  configFile = writeText "config.json" (builtins.toJSON hugoConfig);

in pkgs.mkShell {
  buildInputs = [
    hugo
  ];

  shellHook = ''
    ln -nsf "${configFile}" config.json
  '';
}
