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
    nvim-next = toPlugin "nvim-next" (prev.fetchFromGitHub {
      owner = "ghostbuster91";
      repo = "nvim-next";
      rev = "52bff3f4f5ede1790d3cff295b3b9c4561677415";
      hash = "sha256-0IjHcA9D4X7zZdmFvF3ztRwErWFGdUaivQruGc/6Cj0=";
    });
  });
}
