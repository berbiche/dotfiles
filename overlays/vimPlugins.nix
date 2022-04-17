final: prev: let
  toPlugin = n: v: prev.vimUtils.buildVimPluginFrom2Nix {
    pname = n;
    version = "unstable";
    src = v;
  };
in {
  vimPlugins = prev.vimPlugins.extend (final': prev': {
    # sqlite-lua = prev'.sqlite-lua.overrideAttrs (old: { })
    fterm-nvim = toPlugin "fterm.nvim" (prev.fetchFromGitHub {
      owner = "numToStr";
      repo = "FTerm.nvim";
      rev = "024c76c577718028c4dd5a670552117eef73e69a";
      sha256 = "sha256-Ooan02z82m6hFmwSJDP421QuUqOfjH55X7OwJ5Pixe0=";
    });

    searchbox-nvim = toPlugin "searchbox.nvim" (prev.fetchFromGitHub {
      owner = "VonHeikemen";
      repo = "searchbox.nvim";
      rev = "bbb1c08a36d19517633430079ab0c61293e18b91";
      sha256 = "sha256-vxcqh2ExTUsye19c2jXoPMrbuYojzyz9Dq7UIrxhAdM=";
    });

    desktop-notify-nvim = toPlugin "desktop-notify-nvim" (prev.fetchFromGitHub {
      owner = "HiPhish";
      repo = "desktop-notify-nvim";
      rev = "e1e684226d9b4a7313439bc7dd1be09d72bfb839";
      sha256 = "sha256-cT5XxqGF3RNpQiVn0MXZUFd0PMnBPcE7ioegfqCiUnM=";
    });
  });
}
