{
  description = "Dynamic Music Pill – GNOME Shell Extension";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

                extensionSrc = lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            let
              rel = lib.removePrefix (toString ./. + "/") (toString path);
            in
              rel == "" ||
              builtins.elem rel [
                "metadata.json"
                "extension.js"
                "prefs.js"
                "stylesheet.css"
                "LICENSE"
              ] ||
              rel == "src" ||
              rel == "schemas" ||
              lib.hasPrefix "src/" rel ||
              lib.hasPrefix "schemas/" rel;
        };

                 version =
          if self ? rev then self.rev
          else if self ? dirtyRev then self.dirtyRev
          else "dirty";
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "gnome-shell-extension-dynamic-music-pill";
          inherit version;
          src = extensionSrc;

                    nativeBuildInputs = [ pkgs.glib ];


            installPhase = ''
              runHook preInstall

              extDir="$out/share/gnome-shell/extensions/dynamic-music-pill@andbal"
              mkdir -p "$extDir"

              cp metadata.json extension.js prefs.js stylesheet.css "$extDir"/
            cp -r src "$extDir/"
            cp -r schemas "$extDir/"

            glib-compile-schemas "$extDir/schemas"

            runHook postInstall
            '';

                     meta = {
            description = "An elegant, pill-shaped music player for GNOME Shell";
            homepage = "https://github.com/Andbal23/dynamic-music-pill";
            license = lib.licenses.gpl3Plus;
            platforms = lib.platforms.linux;
            maintainers = [ ];


          };
        };
                checks.default = self.packages.${system}.default;
      }
    )
    // {
      overlays.default = final: prev: {
        gnome-shell-extension-dynamic-music-pill =
          self.packages.${final.system}.default;
      };

      nixosModules.default =
        { config, lib, pkgs, ... }:
        let
          cfg = config.programs.dynamic-music-pill;
        in
        {
          options.programs.dynamic-music-pill.enable =
            lib.mkEnableOption "Dynamic Music Pill GNOME Shell extension";

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [
              self.packages.${pkgs.system}.default
            ];
          };
        };
    };
}
