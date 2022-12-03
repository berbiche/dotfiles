let
  version = "61f96e4cca8ee72abbdadd81af0e828adf24c6d2";
  hash = "sha256-N4Zi/Ul1hYuq5+zUxrfe0yDRjNETQPnTW5GY6lJ3W4Y=";
in
final: prev: {
  rofi-wayland = (prev.rofi.override {
    rofi-unwrapped = prev.rofi-unwrapped.overrideAttrs (drv: {
      inherit version;
      buildInputs = drv.buildInputs or [  ] ++ [ prev.wayland prev.wayland-protocols ];
      nativeBuildInputs = drv.nativeBuildInputs or [ ] ++ [ prev.meson prev.ninja ];
      mesonFlags = [ "-Dxcb=disabled" ];
      src = prev.fetchFromGitHub {
        owner = "lbonn";
        repo = "rofi";
        rev = "${version}";
        hash = "${hash}";
        fetchSubmodules = true;
      };
    });
  }).overrideAttrs (_: {
    pname = "rofi-wayland";
    version = "unstable-2022-11-26";
  });
}
