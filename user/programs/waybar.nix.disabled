{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      withSwayIntegration = true;
    };

    # settings = [{
    #   layer = "top";
    #   position = "top";
    #   height = 30;
    #   output = [
    #     "DP-1"
    #   ];

    #   modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" "custom/hello-from" ];

    #   modules = {
    #     "custom/hello-from" = {
    #       format = "hello {}";
    #       max-length = 40;
    #       interval = 10;
    #       exec = "${pkgs.writers.writeBashBin "hello-from-waybar" ''
    #         echo "from within waybar"
    #       ''}/bin/hello-from-waybar";
    #     };
    #   };
    # }];
  };
}
