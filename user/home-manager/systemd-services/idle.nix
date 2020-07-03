{ pkgs }:

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
