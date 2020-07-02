let
  nix = import ./nix;
  nixpkgs = nix.nixpkgs;
  nixus = import nix.nixus;

  overlays = [ (import ./overlays.nix) ];

  hostConfiguration = ./nixos/host/merovingian.nix;
in
nixus ({ ... }: {
  defaults = { ... }: {
    inherit nixpkgs;
    configuration = { lib, ... }: {
      # Extract the revision number from nixpkgs
      system.nixos.revision = builtins.substring 0 8 nixpkgs.rev;
    };
  };

  nodes.merovingian =
    { ... }:
    {
      host = "root@localhost";
      configuration = {
        imports = [ ./configuration.nix hostConfiguration ];

        my.username = "nicolas";
        my.userHomeConfiguration = ./user/home.nix;
        my.hostname = "merovingian";

        # Mandatory for the deployment with NixOps/Nixus
        services.openssh = {
          enable = true;
          permitRootLogin = "without-password";
          passwordAuthentication = false;
          listenAddresses = [ { addr = "localhost"; port = 22; } ];
        };
        # users.mutableUsers = false;
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtEC0M+d90ew2Otfn/B/gDOJhv+uByid44uAtO4ZV9K"
        ];
      };
    };
})
