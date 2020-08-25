{ config, lib, pkgs, ... }:

let
  inherit (builtins) map attrNames readDir import;
  inherit (lib) filterAttrs hasSuffix;

  # Import all programs under ./programs using their default.nix
  customPrograms = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));
in
{
  home-manager.users.${config.my.username} = {
    imports = customPrograms;

    home.packages = with pkgs; [
      bitwarden bitwarden-cli
      jq                           # cli to extract data out of json input
      hexyl

      signal-desktop
      element-desktop
      spotify
      discord # unfortunately

      # For those rare times
      chromium

      # Essentials
      vscodium
      jetbrains.idea-community

      # Entertainment
      youtube-dl

      # Programming
      #llvmPackages.bintools
      clang
      python3
      gnumake
      powershell
      niv

      # TUIs
      tig            # GIT
      ncdu           # File usage


      # Programming tools
      ###################
      # Postman alternative
      insomnia
    ];

    # Preview directory content and find directory to `cd` to
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
    };

    # ctrl-t, ctrl-r, kill <tab><tab>
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Program prompt
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    # Unavailable on bqv-flakes branch
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      # options = [ "--no-aliases" ];
    };
  };
}
