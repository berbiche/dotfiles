final: prev: {
  i3 = prev.i3.overrideAttrs (drv: {
    patches = drv.patches or [ ] ++ [
      (prev.fetchpatch {
        name = "fix-zoom-floating-windows.patch";
        url = "https://github.com/berbiche/i3/commit/65566acb4c87c58fccc472fa4fabda7b342fda14.patch";
        hash = "sha256-ChK4sPEZFOW+NpDpalGyo56opjmyNu/Z0t5mYWKnGxw=";
      })
    ];
  });
}
