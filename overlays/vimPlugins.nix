final: prev: {
  vimPlugins = prev.vimPlugins.extend (final': prev': {
    # sqlite-lua = prev'.sqlite-lua.overrideAttrs (old: { })
    gitsigns-nvim = prev'.gitsigns-nvim.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "lewis6991";
        repo = "gitsigns.nvim";
        rev = "f46a89978ca523224b3df5291ca0d8278cb30843";
        hash = "sha256-+eD8Z4e3i8e5EnoqfhC+osJDR/pEFsfeLpmZ7mbsF0k=";
      };
    });
    nvim-hlslens = prev'.nvim-hlslens.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "kevinhwang91";
        repo = "nvim-hlslens";
        rev = "0e43dd0cce59d161ab968b4ed45897e946122d9d";
        hash = "sha256-jP/1fYDqCQT0v5VVi+9iaWxEmn2GMKFXmcIClzZmSUY=";
      };
    });
  });
}
