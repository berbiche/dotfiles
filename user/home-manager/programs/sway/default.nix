{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ sway swayidle ];
  xdg.configFile."sway/config".source = ./config;
  xdg.configFile."sway/window-rules.d".source = ./window-rules.d;
  xdg.configFile."sway/config.d".source = ./config.d;

  systemd.user.targets.sway-session = {
    description = "sway compositor session";
    documentation = "man:systemd.special(7)";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
  # Idle service
  systemd.user.services.sway-idle =
    let
      swaylock = "${pkgs.swaylock}/bin/swaylock";
      swayidle = "${pkgs.swayidle}/bin/swayidle";
      swaymsg  = "${pkgs.sway}/bin/swaymsg";
    in
      {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1sec";
          ExecStart = ''
            ${swayidle} -w \
                timeout 300  "${swaylock} -f" \
                timeout 600  "${swaymsg} 'output * dpms off'" \
                resume       "${swaymsg} 'output * dpms on'" \
                before-sleep "${swaylock} -f"
          '';
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
}
