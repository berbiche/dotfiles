final: prev: let
  toPlugin = n: v: prev.vimUtils.buildVimPlugin {
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
      hash = "sha256-cT5XxqGF3RNpQiVn0MXZUFd0PMnBPcE7ioegfqCiUnM=";
    });
    neogit = toPlugin "neogit" (prev.fetchFromGitHub {
      owner = "NeogitOrg";
      repo = "neogit";
      rev = "72403277621bdcc5e3d6799d614becc7da015a26";
      hash = "sha256-Xg03mbZn1s8G3Au3PDPDxuoRFZvv4AF+taDsQ2xV4VI=";
    });
    workspaces-nvim = toPlugin "workspaces.nvim" (prev.fetchFromGitHub {
      owner = "natecraddock";
      repo = "workspaces.nvim";
      rev = "c8bd98990d322b107e58ff5373038b753a8ef66d";
      hash = "sha256-3EgxYbIvglCsh0g9Yu1YBcjzTJlc/Gk68oTmj6/pAHo=";
    });
    fidget-nvim = toPlugin "fidget.nvim" (prev.fetchFromGitHub {
      owner = "j-hui";
      repo = "fidget.nvim";
      # 'legacy' branch
      rev = "90c22e47be057562ee9566bad313ad42d622c1d3";
      hash = "sha256-N3O/AvsD6Ckd62kDEN4z/K5A3SZNR15DnQeZhH6/Rr0=";
    });
    replacer-nvim = toPlugin "replacer.nvim" (prev.fetchFromGitHub {
      owner = "gabrielpoca";
      repo = "replacer.nvim";
      rev = "32e1713230844fa52f7f0598c59295de3c90dc95";
      hash = "sha256-pY0BiclthomTdgJeBFmeVStRFexgsA5V1MU+YGL0OmI=";
    });
    nvim-next = toPlugin "nvim-next" (prev.fetchFromGitHub {
      owner = "ghostbuster91";
      repo = "nvim-next";
      rev = "49eaf4e1731258285791669fdedcee351c59ebdc";
      hash = "sha256-c1ZBThvPj3ep+dyg2vy4Zu7g6po8Q1N/WKGlcDDXIks=";
    });
  });
}
