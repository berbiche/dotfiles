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
      "nrsf" = ''
        set cmd (if test (uname) = Linux; echo nixos-rebuild; else; echo darwin-rebuild; end)
        set sudo (if test (uname) = Linux; echo -- '--use-remote-sudo'; end)
        set -a args $cmd switch $sudo --flake ~/dotfiles -v -L $argv
        echo $args
        $args
      '';
    };
  };
}
