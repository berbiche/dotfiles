# For a tearing-free configuration, picom is used has a compositor
# and the required X11 server configuration has to be set
# at the host/machine level.
# For an example, see host/thixxos services.xserver configuration.
{ config, pkgs, ... }:

{
  imports = [
    ./autorandr.nix
    ./picom.nix
    ./services.nix
    ./i3.nix
  ];

  services.xserver.desktopManager.xfce = {
    enable = true;
    noDesktop = true;
    enableXfwm = false;
  };
  # Important: xfce4-panel must be added as a systemPackage otherwise all defaults modules/plugins
  # are unavailable
  environment.systemPackages = with pkgs; [ lightlocker xfce.xfce4-panel ]
    ++ (map (x: pkgs.xfce."xfce4-${x}-plugin") [
      "battery"
      "clipman"
      "datetime"
      "namebar"
      "dockbarx"
      "embed"
      "hardware-monitor"
      "weather"
      "whiskermenu"
      "windowck"
      "xkb"
    ]);

  my.home = { pkgs, ... }:
   {
    home.packages = with pkgs; [ caffeine-ng xclip ];

    systemd.user.targets.x11-session = {
      Unit = {
        Description = "X11 compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
