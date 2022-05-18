final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (drv: {
    version = "unstable-2022-02-20";
    src = prev.fetchFromGitHub {
      owner = "ErikReider";
      repo = "SwayNotificationCenter";
      rev = "a9c7af237102303908a4392da0dc8e86db60d9d4";
      hash = "sha256-LKt/iB/mNAe0CBuw/0L8iBvnWkUnLzBhGQXA1WgM9SQ=";
    };
    buildInputs = drv.buildInputs or [ ] ++ [ prev.scdoc ];
    patches = drv.patches or [] ++ [
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
  });
}
