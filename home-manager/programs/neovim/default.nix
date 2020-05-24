{ config, lib, pkgs, ... }:

let
  inherit (builtins) fetchTarball;
  inherit (lib) attrNames foldl mapAttrs recursiveUpdate;
  themes = {
    monokai = "https://github.com/sickill/vim-monokai/archive/master.tar.gz";
    anderson = "https://github.com/tlhr/anderson.vim/archive/master.tar.gz";
    synthwave84 = "https://github.com/artanikin/vim-synthwave84/archive/master.tar.gz";
    gruvbox = "https://github.com/morhetz/gruvbox/archive/master.tar.gz";
  };
  tarballs = mapAttrs (_: b: fetchTarball b) themes;
  # Maps a vim theme source to an XDG config file
  toXDGConf = set:
    let
      toXDG = name: value:
        { xdg.configFile."nvim/colors/${name}.vim".source = "${value}/colors/${name}.vim"; };
    in
      foldl (acc: name:
        recursiveUpdate acc (toXDG name set.${name})
      ) { } (attrNames set);
  # Construct an attrset like: xdg.configFile."theme".source = drv/colors/"theme".vim
  configFiles = toXDGConf tarballs;
in
# Merge Themes configuration
(configFiles // {
  # Text-editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    extraConfig = lib.fileContents ./init.vim;
  };
})
