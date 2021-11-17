{ config, pkgs, lib, ... }:

{
  security.pam.u2f.enable = true;
  security.pam.u2f.interactive = false;
  security.pam.u2f.cue = true;
  security.pam.u2f.control = "sufficient";
  security.pam.u2f.appId = "pam://${config.networking.hostName}";

  # Disable u2fAuth for all these modules
  # I only want to enable u2fAuth for ssh, sudo and su really
  security.pam.services = {
    chpasswd.u2fAuth = false;
    i3lock.u2fAuth = false;
    i3lock-color.u2fAuth = false;
    lightdm.u2fAuth = false;
    lightdm-autologin.u2fAuth = false;
    lightdm-greeter.u2fAuth = false;
    login.u2fAuth = false;
    passwd.u2fAuth = false;
    runuser.u2fAuth = false;
    runuser-l.u2fAuth = false;
    swaylock.u2fAuth = false;
    xlock.u2fAuth = false;
    vlock.u2fAuth = false;
    xscreensaver.u2fAuth = false;
  };

  home-manager.sharedModules = [{
    # Get notifications when waiting for my yubikey
    services.yubikey-touch-detector.enable = true;
  }];
}
