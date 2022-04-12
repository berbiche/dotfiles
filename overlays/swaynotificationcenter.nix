final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (drv: {
    version = "unstable-2022-02-20";
    src = prev.fetchFromGitHub {
      owner = "ErikReider";
      repo = "SwayNotificationCenter";
      rev = "188bef8bf90364ee0d76eb07b8e3736ef1382ce5";
      hash = "sha256-0RmYsxpe4rt/BMAqxhaDBh2l5BflFK7p3Hqxu7icPD4=";
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
