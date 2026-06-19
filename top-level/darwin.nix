{
  config,
  pkgs,
  lib,
  inputs,
  rootPath,
  ...
}:

let
  determinateCustomConfLocation = "nix/nix.custom.conf";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.sops-nix.darwinModules.sops
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

    # Configuration to use secret access-tokens
    sops.secrets.nix-config = {
      sopsFile = rootPath + "/secrets/nix-config.cfg";
      mode = "0400";
      format = "binary";
    };

    system.activationScripts.preActivation.text = lib.mkAfter ''
      # Delete the previous determinateNix nix.custom.conf to inject secrets again
      rm -f --one-file-system /etc/${determinateCustomConfLocation}
    '';
    system.activationScripts.postActivation.text = let
      determinateNixConfFile = config.environment.etc."${determinateCustomConfLocation}".source;
      sopsSecret = config.sops.secrets.nix-config.path;
    in lib.mkAfter ''
      # Merges secret nix config into /etc/${determinateCustomConfLocation}
      {
        rm -f --one-file-system /etc/${determinateCustomConfLocation};
        umask 077;
        # Uses a bashism to insert a newline reading from an empty file '<(echo)'
        cat ${lib.escapeShellArg determinateNixConfFile} <(echo) ${lib.escapeShellArg sopsSecret} > /etc/${determinateCustomConfLocation};
      }
    '';

    system.primaryUser = config.my.username;

    # Disable useless warning about NIX_PATH with a flake configuration
    system.checks.verifyNixPath = false;
  };
}
