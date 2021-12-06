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
      rev = "3b625cfd99c4e6046abfde9c13e295ddf18eee08";
      sha256 = "sha256-iy7c9jDkY4ZLvVlJsUJ95uPwArKGtnpI+OiLkdzQ0Tw=";
    });

    dressing-nvim = toPlugin "dressing.nvim" (prev.fetchFromGitHub {
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "683f23ceb1349bb4de402e681daf1176040b28cd";
      sha256 = "sha256-4IrRHlxUhLhLlxbydR/GSBfN5hoLd4m9UhaygMApkz0=";
    });
  });
}
