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
        set mac_sudo (if test (uname) = Darwin; echo sudo; end)
        set -a args $mac_sudo $cmd switch $sudo --flake ~/dotfiles -v -L $argv
        echo $args
        $args
      '';

      last_history_item = ''
        echo $history[1]
      '';
    };

    interactiveShellInit = ''
      abbr --add --position anywhere --function last_history_item -- !!
    '';
  };
}
