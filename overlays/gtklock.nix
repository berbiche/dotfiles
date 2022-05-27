final: prev:
with prev.lib; {
  gtklock = flip prev.callPackage { } (
    { stdenv
    , fetchFromGitHub
    , pkg-config
    , gtk3
    , glib
    , wayland
    , wayland-protocols
    , gtk-layer-shell
    , wrapGAppsHook
    , pam
    }:
    stdenv.mkDerivation rec {
      pname = "gtklock";
      version = "unstable-2022-05-22";

      src = fetchFromGitHub {
        owner = "jovanlanik";
        repo = pname;
        rev = "e8892ccd242cfa06c4791936e7cf7bbcae783b96";
        hash = "sha256-SjCwNXMmCJxLt8wLctf8SbNoWVfAwFy/dGcI3fAPzUo=";
      };

      nativeBuildInputs = [
        pkg-config
        wrapGAppsHook
      ];

      buildInputs = [
        gtk3
        glib
        wayland
        wayland-protocols
        gtk-layer-shell
        pam
      ];

      makeFlags = [ "DESTDIR=${placeholder "out"}" "PREFIX=" ];

      postInstall = ''
        rm -rf $out/etc/pam.d
      '';

      meta = {
        homepage = "https://github.com/jovanlanik/gtklock";
        description = "A GTK-based lockscreen for Wayland";
        platforms = platforms.linux;
        license = licenses.gpl3;
        maintainers = [ maintainers.berbiche ];
      };
    }
  );
}
