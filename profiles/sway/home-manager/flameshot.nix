{ config, lib, ... }:

{
  services.flameshot.enable = true;

  systemd.user.services.flameshot.Install.WantedBy = lib.mkForce [ "sway-session.target" ];

  systemd.user.services.flameshot.Service = {
    # LockPersonality = false;
    RestrictNamespaces = lib.mkForce false;
    SystemCallFilter = lib.mkForce "";
    LockPersonality = lib.mkForce false;
  };
}
