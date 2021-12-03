final: prev: {
  nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (drv: {
    meta = drv.meta or { } // {
      priority = 6;
    };
  });
}
