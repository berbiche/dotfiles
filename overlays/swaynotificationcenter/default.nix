{ lib, stdenv, fetchFromGitHub, fetchpatch
, meson, ninja, pkg-config, vala
, gtk3, glib, gtk-layer-shell
, dbus, dbus-glib, json-glib, librsvg
, libhandy, gobject-introspection, gdk-pixbuf, wrapGAppsHook
}:

stdenv.mkDerivation {
  pname = "SwayNotificationCenter";
  version = "unstable-2021-12-28";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayNotificationCenter";
    rev = "c1eb0525601a5af52fadbf8d20a3522492e25aad";
    hash = "sha256-xo+M8dpqs2tbWQn49PR5ms3TlzMsv9SvY/QN7Jb/MT4=";
  };

  patches = [
    # (fetchpatch {
    #   name = "ellipsize-content.patch";
    #   url = "https://github.com/berbiche/SwayNotificationCenter/commit/9b1f15503a648df656d39e2baed3e4be680383a9.patch";
    #   sha256 = "sha256-S2bVB7FkmNxQ15r0aTlfT8/059E4J8XDiMER6U3K4Vg=";
    # })
    (fetchpatch {
      name = "configurable-notification-center-margins.patch";
      url = "https://github.com/berbiche/SwayNotificationCenter/commit/81c3eddb1389cdbb32e719a8f81410f9c9034f10.patch";
      sha256 = "sha256-IRkAq9RIRs1W0TYP8ZRaucYfNACd9MQOswLL3QHizJg=";
    })
    # (fetchpatch {
    #   name = "configurable-notification-center-width.patch";
    #   url = "https://github.com/berbiche/SwayNotificationCenter/commit/a28fd1b22a6ed337aeff8914337aa91ae594402b.patch";
    #   sha256 = "sha256-+SZuGfuOCI7jg2atMDozD0ZERRG4UIadXPhkik0VRhs=";
    # })
  ];

  nativeBuildInputs = [ meson ninja pkg-config vala gobject-introspection wrapGAppsHook ];

  buildInputs = [ dbus dbus-glib gdk-pixbuf glib gtk-layer-shell gtk3 json-glib libhandy librsvg ];

  postInstall = ''
    sed -i 's|^\s*//.*||' $out/etc/xdg/swaync/config.json
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
