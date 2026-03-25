{
  description = "Dynamic Music Pill – GNOME Shell Extension";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        uuid = "dynamic-music-pill@andbal";
        version = self.shortRev or self.dirtyShortRev or "dev";

        mkExtension = { pname, src, gnomeVersions }:
          pkgs.stdenv.mkDerivation {
            inherit pname src version;

            nativeBuildInputs = [ pkgs.glib ];

            buildPhase = ''
              glib-compile-schemas schemas/
            '';

            installPhase = ''
              runHook preInstall

              extDir=$out/share/gnome-shell/extensions/${uuid}
              mkdir -p $extDir

              cp metadata.json extension.js prefs.js stylesheet.css $extDir/
              cp -r src     $extDir/
              cp -r schemas $extDir/
              cp -r locale  $extDir/

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "An elegant, pill-shaped music player for your GNOME desktop (GNOME ${gnomeVersions})";
              homepage = "https://github.com/Andbal23/dynamic-music-pill";
              license = licenses.gpl3Plus;
              platforms = platforms.linux;
            };
          };
      in
      {
        packages = {
          # GNOME 45-49 (default)
          default = mkExtension {
            pname = "gnome-shell-extension-dynamic-music-pill";
            src = ./.;
            gnomeVersions = "45-49";
          };

          # GNOME 50
          gnome50 = mkExtension {
            pname = "gnome-shell-extension-dynamic-music-pill-gnome50";
            src = ./dynamic-music-pill-gnome50;
            gnomeVersions = "50";
          };
        };
      }
    );
}
