/*
 * My Neovim configuration is under ./home-manager/neovim
 */
{ config, lib, isDarwin, ... }:

lib.optionalAttrs isDarwin {
  homebrew.casks = [
    "vimr"
  ];
}
