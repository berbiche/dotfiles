{ config, pkgs, lib, ... }:

{
  # Thanks to type merging, the default value of u2fAuth can be set to false
  # for all pam modules :)
  options.security.pam.services = with lib; mkOption {
    type = types.attrsOf (types.submodule {
      # Instead of overriding options.*.default, set it in the config section of the module
      config.u2fAuth = mkDefault false;
      config.yubicoAuth = mkDefault false;
    });
  };

  config = {
    security.pam.u2f.enable = true;
    security.pam.u2f.interactive = false;
    security.pam.u2f.cue = true;
    security.pam.u2f.control = "sufficient";
    security.pam.u2f.appId = "pam://${config.networking.hostName}";

    security.pam.services = {
      su.u2fAuth = true;
      sudo.u2fAuth = true;
      sshd.u2fAuth = true;
      polkit-1.u2fAuth = true;
    };

    home-manager.sharedModules = [{
      # Get notifications when waiting for my yubikey
      services.yubikey-touch-detector.enable = true;
    }];
  };
}
