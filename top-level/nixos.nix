{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];

  nix = {
    nixPath = [
      # Pin nixpkgs for older Nix tools (nix-shell, nix repl, etc.)
      "nixpkgs=${pkgs.path}"
    ];
    allowedUsers = [ "root" "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-wayland.flake = inputs.nixpkgs-wayland;
    };

    # Run monthly garbage collection to reduce store size
    gc.dates = "monthly";
    # Optimize (hardlink duplicates) store automatically
    autoOptimiseStore = true;

    # Reduce IOnice and CPU niceness of the build daemon
    daemonIONiceLevel = 3;
    daemonNiceLevel = 10;
  };

  # We need this to generate the sops host key
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  services.openssh.permitRootLogin = "no";
  services.openssh.passwordAuthentication = false;

  location.longitude = config.my.location.longitude;
  location.latitude = config.my.location.latitude;
}
