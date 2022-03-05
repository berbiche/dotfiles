final: prev: {
  ulauncher = prev.ulauncher.overrideAttrs (drv: rec {
    version = "5.14.2";
    src = prev.fetchurl {
      url = "https://github.com/Ulauncher/Ulauncher/releases/download/${version}/ulauncher_${version}.tar.gz";
      sha256 = "sha256-5Id70t5pyZmW5OOsXICDs+49GxgrDkpdUqOvE03Y1HU=";
    };
    patches = [
      ./ulauncher/0001-Adjust-get_data_path-for-NixOS.patch
      ./ulauncher/fix-extensions.patch
      ./ulauncher/fix-path.patch
    ];
  });
}
