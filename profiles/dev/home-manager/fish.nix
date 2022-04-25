{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      "..."  = "../../";
      "...." = "../../../";
      "....." = "../../../../";
    };

    functions = {
      "nrsf" = lib.mkIf isLinux ''
        set -a args nixos-rebuild switch --use-remote-sudo --flake ~/dotfiles -v -L $argv
        echo $args
        $args
      '';
    };
  };
}
