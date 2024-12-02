{ inputs, config, pkgs, ... }:

{
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
      use-xdg-base-directories = true;
      # Override the global registry because it should never have existed
      flake-registry = "";
      nix-path = [
        # Point to a stable path so system updates immediately update <nixpkgs> references
        # Useful with `nix repl <nixpkgs>` and other commands
        "nixpkgs=${config.home.profileDirectory}/nixpkgs"
      ];
    };
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
  };
  # Link nixpkgs path to ${config.home.profileDirectory}/nixpkgs for previous feature to work
  home.extraProfileCommands = ''
    ln -s ${pkgs.path} "$out"/nixpkgs
  '';

  home.shellAliases = {
    hm = "home-manager";
  };
}
