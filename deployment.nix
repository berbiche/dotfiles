{ username
, hostname
, hostConfiguration
, userHomeConfiguration ? ./user/home.nix
, homeManagerModule ? null
}:

let
  sources = import ./nix/sources.nix;
in
{
  network.description = "persephone";
  network.enableRollback = true;
  network.nixpkgs = sources.nixpkgs;

  merovingian =
    { ... }:
    {
      imports = [ ./configuration.nix hostConfiguration ];

      deployment.targetHost = "localhost";
      deployment.privilegeEscalationCommand = [ "sudo" ];

      inherit username userHomeConfiguration;
      hostname = "merovingian";

      # Mandatory for NixOps
      services.openssh = {
        enable = true;
        permitRootLogin = "without-password";
        passwordAuthentication = false;
        listenAddresses = [ { addr = "127.0.0.1"; port = 22; } ];
      };
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtEC0M+d90ew2Otfn/B/gDOJhv+uByid44uAtO4ZV9K"
      ];
    };
}
