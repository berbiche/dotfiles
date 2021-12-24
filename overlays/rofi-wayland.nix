let
  version = "1.7.2+wayland1";
  hash = "sha256-INFYHOVjBNj8ks4UjKnxLW8mL7h1c8ySFPS/rUxOWwo=";
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
    inherit version;
  });
}
