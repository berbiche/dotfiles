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
    workspaces-nvim = toPlugin "workspaces.nvim" (prev.fetchFromGitHub {
      owner = "natecraddock";
      repo = "workspaces.nvim";
      rev = "c6f19b08123eaee37d27561299f2b4f1385fa9f0";
      hash = "sha256-JGe+htJq1aYT4fWpQ4r+ZVbBSiTETk+OakruFQDubk4=";
    });
    # fidget-nvim = toPlugin "fidget.nvim" (prev.fetchFromGitHub {
    #   owner = "j-hui";
    #   repo = "fidget.nvim";
    #   # 'legacy' branch
    #   rev = "90c22e47be057562ee9566bad313ad42d622c1d3";
    #   hash = "sha256-N3O/AvsD6Ckd62kDEN4z/K5A3SZNR15DnQeZhH6/Rr0=";
    # });
    trouble-nvim = toPlugin "trouble.nvim" (prev.fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      # 'dev' branch for v3 version
      rev = "b4b9a11b3578d510963f6f681fecb4631ae992c3";
      hash = "sha256-TjQ8UiV1BqmAddhu9iu+X1HbmCS6SQoIOyXbe8gZRqo=";
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
      rev = "52bff3f4f5ede1790d3cff295b3b9c4561677415";
      hash = "sha256-0IjHcA9D4X7zZdmFvF3ztRwErWFGdUaivQruGc/6Cj0=";
    });
  });
}
