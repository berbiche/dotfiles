{ config, pkgs, lib, ... }:

{
  security.pam.yubico.enable = true;
  security.pam.yubico.control = "sufficient";
  security.pam.yubico.mode = "challenge-response";

  home-manager.sharedModules = [{
    # Get notifications when waiting for my yubikey
    services.yubikey-touch-detector.enable = true;
  }];
}
