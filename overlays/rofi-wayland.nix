let
  version = "1.7.0+wayland1";
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
        sha256 = "sha256-x+kgbd7pBCWDf7czJMlk2HzbwnnF/ix8NPr3mSmB1MA=";
        fetchSubmodules = true;
      };
    });
  }).overrideAttrs (_: {
    pname = "rofi-wayland";
    inherit version;
  });
}
