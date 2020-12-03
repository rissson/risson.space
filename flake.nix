{
  #name = "yabob";
  description = "risson's blog: Yet Another Boring Ops Blog";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, futils }:
    let
      inherit (nixpkgs) lib;
      inherit (futils.lib) eachDefaultSystem defaultSystems;
      inherit (lib) recursiveUpdate genAttrs substring;

      nixpkgsFor = genAttrs defaultSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });

      version = "0.0.${substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}_${self.shortRev or "dirty"}";

      hugoConfig = pkgs: { baseURL ? "https://risson.space/", theme ? "slick", isProduction ? true }:
        pkgs.writeText "config.json" (builtins.toJSON (import ./config.nix {
          inherit baseURL theme isProduction;
          themesDir = pkgs.linkFarm "themesDir" [
            { name = "slick"; path = pkgs.hugoThemes.slick; }
          ];
        }));
    in
    recursiveUpdate

    {
      overlay = final: prev: {
        hugoThemes.slick = final.stdenvNoCC.mkDerivation rec {
          pname = "slick";
          version = "0.3.2";

          src = final.fetchFromGitHub {
            owner = "spookey";
            repo = "slick";
            rev = "v${version}";
            sha256 = "13432bmj61xfpn6s02mlb229660l882xn0mxs6p5fx1v0nmqm6d4";
          };

          installPhase = ''
            cp -r $src $out
          '';

          meta = with final.stdenv.lib; {
            description = "A fast, minimal, responsive theme for Hugo which honours your privacy";
            maintainers = with maintainers; [ risson ];
            license = licenses.mit;
            platforms = platforms.unix;
          };
        };

        yabob = final.stdenvNoCC.mkDerivation rec {
          pname = "yabob";
          inherit version;

          src = ./.;

          configFile = hugoConfig final { };

          buildInputs = [ final.hugo ];

          buildPhase = ''
            hugo \
              --config $configFile \
              --cleanDestinationDir \
              --forceSyncStatic \
              --ignoreCache \
              --ignoreVendor \
              --minify
          '';

          installPhase = ''
            cp -r public $out
          '';

          meta = with final.stdenv.lib; {
            inherit (self) description;
            maintainers = with maintainers; [ risson ];
            license = licenses.mit;
            platforms = platforms.unix;
          };
        };

        yabob-dev = final.yabob.overrideAttrs (old: {
          configFile = hugoConfig final {
            baseURL = "https://dev.risson.space";
          };
        });
      };
    }

    (eachDefaultSystem (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.yabob ];

          configFile = hugoConfig pkgs {
            isProduction = false;
          };
          shellHook = ''
            ln -nsf $configFile config.json
          '';
        };

        packages = {
          inherit (pkgs) yabob yabob-dev;
          hugoThemes = {
            inherit (pkgs.hugoThemes) slick;
          };
        };
        defaultPackage = self.packages.${system}.yabob;
      }
    ));
}
