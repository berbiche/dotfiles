final: prev: {
  ulauncher = prev.ulauncher.overrideAttrs (drv: rec {
    version = "5.14.7";
    src = prev.fetchurl {
      url = "https://github.com/Ulauncher/Ulauncher/releases/download/${version}/ulauncher_${version}.tar.gz";
      sha256 = "sha256-gR4DZLrQCmZXuFrU80wQ/VOvyPcvztslgCFUFJ7XhpU=";
    };
    nativeBuildInputs = drv.nativeBuildInputs or [] ++ [ prev.gobject-introspection ];
    patches = [
      ./ulauncher/0001-Adjust-get_data_path-for-NixOS.patch
      ./ulauncher/fix-extensions.patch
      ./ulauncher/fix-path.patch
      (prev.substituteAll {
        src = ./ulauncher/fix-libx11-path.patch;
        libx11_path = "${prev.xorg.libX11}/lib/libX11${prev.stdenv.hostPlatform.extensions.sharedLibrary}";
      })
    ];
  });
}
