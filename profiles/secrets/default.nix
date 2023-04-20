{ config, pkgs, ... }:

{
  imports = [
    ./gpg.nix
  ];

  my.home.imports = [ ./home-manager.nix ];

  home-manager.sharedModules = [ ({ pkgs, ... }: {
    home.packages = [ pkgs.age pkgs.sops ];
  }) ];
}
