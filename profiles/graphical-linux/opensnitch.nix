{ ... }:

{
  services.opensnitch.enable = true;

  home-manager.sharedModules = [{
    services.opensnitch-ui.enable = true;
  }];
}
