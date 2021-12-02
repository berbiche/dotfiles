{ config, lib, pkgs, ... }:

{
  programs.rofi.enable = true;
  programs.rofi.package = pkgs.rofi-wayland;
  programs.rofi.plugins = [
    pkgs.rofi-calc
    pkgs.rofi-emoji
    pkgs.rofi-file-browser
  ];
  programs.rofi.terminal = config.wayland.windowManager.sway.config.terminal;
  programs.rofi.extraConfig = {
    modi = "drun,run";

    show-icons = true;
    drun-show-actions = true;

    sort = true;
    sorting-method = "fzf";
    matching = "fuzzy";

    run-command = "${pkgs.sway}/bin/swaymsg exec -- {cmd}";
    drun-url-launher = "${pkgs.sway}/bin/swaymsg -- ${pkgs.xdg_utils}/bin/xdg-open";

    # file-browser = {
    #   directories-first = true;
    #   sorting-method = "name";
    # };
  };

  xdg.configFile."rofi/themes" = let
    rofi-themes = pkgs.fetchFromGitHub {
      owner = "davatorium";
      repo = "rofi-themes";
      rev = "bfdde8e7912ad50a468c721b29b448c1ec5fa5e3";
      sha256 = "sha256-w/AE1o8vIZdD0jAi7++gdlmApGjeyDv6CD4xxrD9Fsw=";
    };
  in {
    recursive = true;
    source = pkgs.runCommandLocal "rofi-themes" { src = rofi-themes; } ''
      mkdir -p "$out"
      cp -rs --no-clobber --no-preserve=mode "$src/Official Themes/." "$src/User Themes/." "$out"
    '';
  };
}
