let
  load =
    y: x: if builtins.pathExists (y + "/${x}.nix") then y + "/${x}.nix" else y + "/${x}/default.nix";
in
{
  hostname,
  username,
  isLinux,
  allowUnfree ? true,
  hostConfiguration ? load ../host hostname,
  userConfiguration ? load ../user username,
  extraModules ? [ ],
}:
let
  defaults =
    {
      config,
      pkgs,
      lib,
      inputs,
      ...
    }:
    {
      imports = [
        hostConfiguration
        userConfiguration
      ]
      ++ extraModules;

      environment.systemPackages = [ pkgs.cachix ];

      networking.hostName = lib.mkDefault hostname;

      nixpkgs.config.allowUnfree = allowUnfree;

      environment.variables."DETSYS_IDS_TELEMETRY" = "disabled";
      determinateNix = {
        enable = true;

        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };

        customSettings = {
          # experimental-features = ["nix-command" "flakes"];
          keep-outputs = true;
          keep-derivations = true;
          # Override the global registry because it should never have existed
          # flake-registry = lib.mkForce "";
          use-registries = true;

          nix-path = [
            # Point to a stable path so system updates immediately update
            # "nixpkgs=/run/current-system/nixpkgs"
            "nixpkgs=flake:nixpkgs"
          ];
        };
      };

      # Link nixpkgs path to /run/current-system/nixpkgs
      system.systemBuilderCommands = ''
        ln -s ${lib.escapeShellArg pkgs.path} "$out"/nixpkgs
      '';

      # My custom user settings
      my.username = username;
    };
in
[
  ./module.nix
  ./home-manager.nix
  ../cachix.nix
  defaults
]
