let
  load = y: x:
    if builtins.pathExists (y + "/${x}.nix") then
      y + "/${x}.nix"
    else
      y + "/${x}/default.nix";
in
{ hostname
, username
, isLinux
, hostConfiguration ? load ../host hostname
, userConfiguration ? load ../user username
, extraModules ? [ ]
}:
let
  defaults = { config, pkgs, lib, ... }: {
    imports = [ hostConfiguration userConfiguration ] ++ extraModules;

    environment.systemPackages = [ pkgs.cachix ];

    networking.hostName = lib.mkDefault hostname;

    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
      # Automatic GC of nix files
      gc = {
        automatic = true;
        options = "--delete-older-than 10d";
      };
    };
    # My custom user settings
    my = { inherit username; };
  };
in [
  ./lib.nix
  ./module.nix
  ./home-manager.nix
  ../cachix.nix
  defaults
]
