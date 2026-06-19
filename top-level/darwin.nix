{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{

  # This option will never be read on Darwin since sops-nix does not
  # support MacOS and is not loaded
  options.sops = lib.mkSinkUndeclaredOptions { };
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.determinate.darwinModules.default
  ];

  config = {
    my.defaults.file-explorer = "";

    system.stateVersion = 4;

    # I already do this in ./mkConfig.nix
    # nixpkgs.flake.setNixPath = false;
    # nixpkgs.flake.setFlakeRegistry = false;

    # nix.nixPath = [
    #   "darwin=${inputs.nix-darwin}"
    # ];
    # nix.settings.extra-sandbox-paths = [
    #   # Necessary
    #   "/System/Library/Frameworks"
    #   # Necessary
    #   "/System/Library/PrivateFrameworks"
    #   # Probably necessary
    #   "/usr/lib"
    # ];

    determinateNix.customSettings.allowed-users = [
      "@admin"
      config.my.username
    ];
    determinateNix.customSettings.trusted-users = [
      "@admin"
      config.my.username
    ];

    system.primaryUser = config.my.username;

    # Disable useless warning about NIX_PATH with a flake configuration
    system.checks.verifyNixPath = false;
  };
}
