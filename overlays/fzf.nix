final: prev: {
  fzf = prev.fzf.overrideAttrs (drv: {
    patches = drv.patches or [ ] ++ [
      (prev.fetchpatch {
        url = "https://github.com/berbiche/fzf/commit/42ccb095952b1b75a7bca683c84d16bd39121b0f.patch";
        hash = "sha256-FS/D2xwnLMD7eoKCkZKTPLIom68uJ+/OH5aq3OgIgsQ=";
      })
    ];
  });
}
