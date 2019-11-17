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
      Environment = ''"PATH=${pkgs.coreutils}/bin:${pkgs.swayidle}/bin:${pkgs.swaylock}/bin:${pkgs.sway}/bin"'';
      ExecStart = builtins.concatStringsSep " " [
        "${swayidle} -w"
          "timeout 300"  ''"${swaylock} -f"''
          "timeout 600"  ''"${swaymsg} \"output * dpms off\""''
          "resume"       ''"${swaymsg} \"output * dpms on\""''
          "before-sleep" ''"${swaylock} -f"''
      ];
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
