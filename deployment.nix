let
  nix = import ./nix;
  nixpkgs = nix.nixpkgs;
  nixus = import nix.nixus;

  overlays = [ (import ./overlays.nix) ];

  hostConfiguration = ./nixos/host/merovingian.nix;
in
nixus ({ ... }: {
  defaults = { name, ... }: {
    inherit nixpkgs;
    configuration = { lib, ... }: {
      networking.hostName = lib.mkDefault name;
      nixpkgs = import nixpkgs { inherit overlays; };
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
          listenAddresses = [ { addr = "127.0.0.1"; port = 22; } ];
        };
        users.mutableUsers = false;
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtEC0M+d90ew2Otfn/B/gDOJhv+uByid44uAtO4ZV9K"
        ];
      };
    };
})
