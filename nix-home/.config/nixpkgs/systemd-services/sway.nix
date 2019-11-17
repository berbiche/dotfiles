pkgs:
{
#  sway = {
#    Unit = {
#      Description = "A i3 compatible Wayland compositor";
#      Documentation = [ "man:sway(1)" ];
#      BindsTo =  [ "graphical-session.target" ];
#      Wants = [ "graphical-session.target" ];
#      Requisite = [ "dbus.service" ];
#      After = [ "dbus.service" "graphical-session-pre.target" ];
#      Before = [ "sway-session.target" ];
#      StartLimitIntervalSec = 1;
#    };
#    
#    Service = {
#      Type = "simple";
#      ExecStart = builtins.concatStringsSep " " [ ''"${pkgs.sway}/bin/sway"'' "--config" ''"%E/sway/config"'' "-d" ];
#      ExecReload = "${pkgs.sway}/bin/swaymsg reload";
#      Restart = "on-failure";
#      RestartSec = "1sec";
#      OOMPolicy = "continue";
#    };
#
#    Install = {
#      # WantedBy = [ "graphical-session.target" ];
#    };
#  };
}
