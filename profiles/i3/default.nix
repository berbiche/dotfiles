{ config, lib, pkgs, ... }:

{
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  my.home = {
    imports = [ ./home-manager ];
    xsession.windowManager.i3.package = lib.mkForce (
      pkgs.runCommandLocal "dummy-i3" { } ''
        mkdir -p "$out"/bin
        touch "$out"/bin/i3
        chmod +x "$out"/bin/i3
      ''
    );
  };
}
