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
    , scdoc
    }:
    stdenv.mkDerivation rec {
      pname = "gtklock";
      version = "unstable-2022-08-12";

      src = fetchFromGitHub {
        owner = "jovanlanik";
        repo = pname;
        rev = "e67be9ff0c1c33ec04e8e8d96ebc965972a9bb38";
        hash = "sha256-cwV6yCSKwIM5V8VvoMsj5W50cvfBAAvSrgLhSkfAYR4=";
      };

      nativeBuildInputs = [
        pkg-config
        wrapGAppsHook
        scdoc
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
