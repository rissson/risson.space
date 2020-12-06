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

      hugoConfig = pkgs: { baseURL ? "https://risson.space/", theme ? "smol", isProduction ? true }:
        pkgs.writeText "config.json" (builtins.toJSON (import ./config.nix {
          inherit baseURL theme isProduction;
          themesDir = pkgs.linkFarm "themesDir" [
            { name = "smol"; path = pkgs.hugoThemes.smol; }
          ];
        }));
    in
    recursiveUpdate

    {
      overlay = final: prev: {
        hugoThemes.smol = final.stdenvNoCC.mkDerivation rec {
          pname = "smol";
          version = "unstable";

          src = final.fetchFromGitHub {
            owner = "colorchestra";
            repo = "smol";
            rev = "b4a26052227c37a768846af47dfedeeab187b3f7";
            sha256 = "0y2z6giy38fa9bmdcjvan5mpyyyl7yw9lz9hlhm8nxrrgsq54psf";
          };

          installPhase = ''
            cp -r $src $out
          '';

          meta = with final.stdenv.lib; {
            description = ''
              A minimal, monospaced blogging theme for Hugo that respects your
              privacy and is easy on your bandwidth.
            '';
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
            inherit (pkgs.hugoThemes) slick temple;
          };
        };
        defaultPackage = self.packages.${system}.yabob;
      }
    ));
}
