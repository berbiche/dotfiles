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
  });
}
