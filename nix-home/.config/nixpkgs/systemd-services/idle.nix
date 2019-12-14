pkgs:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
  swayidle = "${pkgs.swayidle}/bin/swayidle";
  swaymsg  = "${pkgs.sway}/bin/swaymsg";
in
{
  idle = {
    Unit = {
      Description = "Idle manager for Wayland";
      Documentation = "man:swayidle(1)";
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1sec";

      # Dirty workaround a missing executable (which one??) `execve failed! No such file or directory`
      Environment = ''"PATH=/run/current-system/sw/bin:$PATH"'';

      #Environment = ''"PATH=${pkgs.coreutils}/bin:${pkgs.swayidle}/bin:${pkgs.swaylock}/bin:${pkgs.sway}/bin:${pkgs.dbus}/bin:${pkgs.xdg-dbus-proxy}/bin:$PATH"'';
      ExecStart = builtins.concatStringsSep " " [
        "${swayidle} -w"
          "timeout 300"  ''"${swaylock} -f"''
          "timeout 600"  ''"${swaymsg} \"output * dpms off\""''
          "resume"       ''"${swaymsg} \"output * dpms on\""''
          "before-sleep" ''"${swaylock} -f"''
      ];
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
