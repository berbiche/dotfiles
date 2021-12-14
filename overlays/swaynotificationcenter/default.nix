{ lib, stdenv, fetchFromGitHub
, meson, ninja, pkg-config, vala
, gtk3, glib, gtk-layer-shell
, dbus, dbus-glib, json-glib, librsvg
, libhandy, gobject-introspection, gdk-pixbuf, wrapGAppsHook
}:

stdenv.mkDerivation {
  pname = "SwayNotificationCenter";
  version = "unstable-2021-07-21";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayNotificationCenter";
    rev = "75894f50ff49b31e9024df3fe6ce97f09f6eb6ad";
    hash = "sha256-yZ0Kqcfk67fa/Yl9N60h7hHbyTbS+iV8u1y2pu8zYYA=";
  };

  patches = [
    ./dont-bind-gtk-layer-shell-bottom.patch
    ./ellipsize-content.patch
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
