{ config, lib, inputs, isLinux, rootPath, ... }:

{
  # nix.nixPath = [
  #   # For Manix
  #   "home-manager=${inputs.home-manager}"
  # ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    verbose = true;
  };
  home-manager.extraSpecialArgs = {
    inherit inputs rootPath lib;
    isLinux = isLinux;
    isDarwin = !isLinux;
  };
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
    (hmArgs: {
      # Specify Home Manager version compability
      home.stateVersion = "25.11";
      # Use the new systemd service activation/deactivation tool
      # See https://github.com/nix-community/home-manager/pull/1656
      # systemd.user.startServices = "sd-switch";

      # This should be the default setting because
      # inheriting the PATH from the environment during the activation is impure
      home.emptyActivationPath = true;
      # Home Manager's activation script fails on Darwin because it cannot run `nix-build`
      # home.extraActivationPath = [ config.nix.package ];

      nix.enable = false;
      nix.assumeXdg = true;

      xdg.configFile."nix/nix.conf".text = lib.mkIf (!hmArgs.config.nix.enable) ''
        # Managed by Home-Manager (config.nix.enable = false)
        # config.nix.extraOptions will follow
        ${hmArgs.config.nix.extraOptions}
      '';
    })
  ];
}
