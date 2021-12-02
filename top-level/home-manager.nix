{ config, lib, inputs, isLinux, rootPath, ... }:

{
  nix.nixPath = [
    # For Manix
    "home-manager=${inputs.home-manager}"
  ];
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
    {
      # Specify Home Manager version compability
      home.stateVersion = "21.11";
      # Use the new systemd service activation/deactivation tool
      # See https://github.com/nix-community/home-manager/pull/1656
      systemd.user.startServices = "sd-switch";

    }
  ];
}
