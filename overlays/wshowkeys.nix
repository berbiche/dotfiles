final: prev: {
  wshowkeys = prev.wshowkeys.overrideAttrs (old: {
    version = "2021-08-01";
    src = prev.fetchFromGitHub {
      owner = "ammgws";
      repo = "wshowkeys";
      rev = "e8bfc78f08ebdd1316daae59ecc77e62bba68b2b";
      hash = "sha256-/HvNCQWsXOJZeCxHWmsLlbBDhBzF7XP/SPLdDiWMDC4=";
    };
    meta.broken = false;
  });
}
