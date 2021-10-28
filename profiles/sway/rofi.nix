{ lib, pkgs, ... }:

{
  my.home = { config, ... }: {
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
  };
}
