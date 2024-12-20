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
      package = pkgs.nix;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        keep-outputs = true;
        keep-derivations = true;
        # Override the global registry because it should never have existed
        flake-registry = "";
        use-registries = true;
      };
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
      };
      # Automatic GC of nix files
      gc = {
        automatic = true;
        options = "--delete-older-than 10d";
      };
      nixPath = [
        # Point to a stable path so system updates immediately update
        "nixpkgs=/run/current-system/nixpkgs"
      ];
    };

    # Link nixpkgs path to /run/current-system/nixpkgs
    system.systemBuilderCommands = ''
      ln -s ${lib.escapeShellArg pkgs.path} "$out"/nixpkgs
    '';

    # My custom user settings
    my.username = username;
  };
in [
  ./module.nix
  ./home-manager.nix
  ../cachix.nix
  defaults
]
