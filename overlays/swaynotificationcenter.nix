final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (drv: {
    version = "unstable-2022-08-15";
    src = prev.fetchFromGitHub {
      owner = "ErikReider";
      repo = "SwayNotificationCenter";
      rev = "57721c221e67765d9510e96c08bc15d43833ebb2";
      hash = "sha256-TaGd2xHRv/jVI0bA0hcDNGgKpkwMf72gLuN2YL2XvkY=";
    };
    buildInputs = drv.buildInputs or [] ++ [ prev.python3 ];
    postPatch = drv.postPatch or "" + ''
      chmod +x build-aux/meson/postinstall.py
      patchShebangs build-aux/meson/postinstall.py
    '';
  });
}
