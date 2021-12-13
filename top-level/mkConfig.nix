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
, allowUnfree ? true
, hostConfiguration ? load ../host hostname
, userConfiguration ? load ../user username
, extraModules ? [ ]
}:
let
  defaults = { config, pkgs, lib, inputs, ... }: {
    imports = [ hostConfiguration userConfiguration ] ++ extraModules;

    environment.systemPackages = [ pkgs.cachix ];

    networking.hostName = lib.mkDefault hostname;

    nixpkgs.config.allowUnfree = allowUnfree;
    nix = {
      package = pkgs.nix_2_4;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true

        # Override the global registry because it should never have existed
        flake-registry = ${builtins.toFile "flake-registry" (builtins.toJSON { version = 2; flakes = [ ]; })}
      '';
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nur = {
          from = { type = "indirect"; id = "nur"; };
          to = { type = "github"; owner = "berbiche"; repo = "nur-flake-wrapper"; };
          exact = true;
        };
      };
      # Automatic GC of nix files
      gc = {
        automatic = true;
        options = "--delete-older-than 10d";
      };
    };
    # My custom user settings
    my.username = username;
  };
in [
  ./module.nix
  ./home-manager.nix
  ../cachix.nix
  defaults
]
