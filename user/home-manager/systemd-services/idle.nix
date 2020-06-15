{ pkgs }:

let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
  swayidle = "${pkgs.swayidle}/bin/swayidle";
  swaymsg  = "${pkgs.sway}/bin/swaymsg";

  script = pkgs.writeShellScriptBin "idle.sh" ''
    ${swayidle} -w \
        timeout 300  "${swaylock} -f" \
        timeout 600  "${swaymsg} 'output * dpms off'" \
        resume       "${swaymsg} 'output * dpms on'" \
        before-sleep "${swaylock} -f"
  '';
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
      #Environment = ''"PATH=/run/current-system/sw/bin:$PATH"'';

      Environment = "PATH=${
        pkgs.lib.makeBinPath
          (with pkgs; [ coreutils swayidle swaylock sway dbus xdg-dbus-proxy ])
      }";

      ExecStart = "${script}/bin/idle.sh";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
