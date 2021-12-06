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
      nur = {
        from = { type = "indirect"; id = "nur"; };
        to = { type = "github"; owner = "berbiche"; repo = "nur-flake-wrapper"; };
        exact = true;
      };
    };

    # Run monthly garbage collection to reduce store size
    gc.dates = "monthly";
    # Optimize (hardlink duplicates) store automatically
    autoOptimiseStore = true;

    # Make the daemon and builders low priority to have a responding system while building
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
  };

  # We need this to generate the sops host key
  services.openssh.enable = true;
  services.openssh.openFirewall = lib.mkDefault false;
  services.openssh.permitRootLogin = lib.mkDefault "no";
  services.openssh.passwordAuthentication = lib.mkDefault false;

  location.longitude = lib.mkIf (config.my.location != null) config.my.location.longitude;
  location.latitude = lib.mkIf (config.my.location != null) config.my.location.latitude;
}
