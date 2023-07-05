final: prev: let
  toPlugin = n: v: prev.vimUtils.buildVimPluginFrom2Nix {
    pname = n;
    version = "unstable";
    src = v;
  };
in {
  vimPlugins = prev.vimPlugins.extend (final': prev': {
    desktop-notify-nvim = toPlugin "desktop-notify-nvim" (prev.fetchFromGitHub {
      owner = "HiPhish";
      repo = "desktop-notify-nvim";
      rev = "e1e684226d9b4a7313439bc7dd1be09d72bfb839";
      sha256 = "sha256-cT5XxqGF3RNpQiVn0MXZUFd0PMnBPcE7ioegfqCiUnM=";
    });
    neogit = toPlugin "neogit" (prev.fetchFromGitHub {
      owner = "NeogitOrg";
      repo = "neogit";
      rev = "72824006f2dcf775cc498cc4a046ddd2c99d20a3";
      sha256 = "sha256-1DEzVPHL+l8y2PHWcAg/bPBA+E/5riMa6pon3vvyQag=";
    });
  });
}
