final: prev: {
  john = prev.john.overrideAttrs (drv: {
    patches = drv.patches or [ ] ++ [
      (prev.fetchpatch {
        name = "fix-gcc-11-compilation-error.patch";
        url = "https://github.com/openwall/john/commit/8152ac071bce1ebc98fac6bed962e90e9b92d8cf.patch";
        hash = "sha256-3rfS2tu/TF+KW2MQiR+bh4w/FVECciTooDQNTHNw31A=";
      })
    ];
  });
}
