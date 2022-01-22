{ lib, stdenv, fetchFromGitHub, fetchpatch
, meson, ninja, pkg-config, vala
, gtk3, glib, gtk-layer-shell
, dbus, dbus-glib, json-glib, librsvg
, libhandy, gobject-introspection, gdk-pixbuf, wrapGAppsHook
}:

stdenv.mkDerivation {
  pname = "SwayNotificationCenter";
  version = "unstable-2022-01-16";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayNotificationCenter";
    rev = "998f7e286d000764a775fac0a18533351206101b";
    hash = "sha256-dwyfalc3lRBnwM5eHGFmBPGfLbyZoHHeAd/yOVAeD7E=";
  };

  patches = [
    # (fetchpatch {
    #   name = "ellipsize-content.patch";
    #   url = "https://github.com/berbiche/SwayNotificationCenter/commit/9b1f15503a648df656d39e2baed3e4be680383a9.patch";
    #   sha256 = "sha256-S2bVB7FkmNxQ15r0aTlfT8/059E4J8XDiMER6U3K4Vg=";
    # })
    # (fetchpatch {
    #   name = "configurable-notification-center-width.patch";
    #   url = "https://github.com/berbiche/SwayNotificationCenter/commit/a28fd1b22a6ed337aeff8914337aa91ae594402b.patch";
    #   sha256 = "sha256-+SZuGfuOCI7jg2atMDozD0ZERRG4UIadXPhkik0VRhs=";
    # })
  ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection wrapGAppsHook ];

  buildInputs = [ dbus dbus-glib gdk-pixbuf glib gtk-layer-shell gtk3 json-glib libhandy librsvg ];

  postInstall = ''
    # sed -i 's|^\s*//.*||' $out/etc/xdg/swaync/config.json
    # wrapProgram "$out"/bin/swaync --prefix XDG_DATA_DIRS "$out/etc/xdg"
    # wrapProgram "$out"/bin/swaync-client --prefix XDG_DATA_DIRS "$out/etc/xdg"
  '';

  meta = with lib; {
    description = "A simple notification daemon with a gui built for Sway";
    homepage = "https://github.com/ErikReider/SwayNotificationCenter";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.berbiche ];
  };
}
