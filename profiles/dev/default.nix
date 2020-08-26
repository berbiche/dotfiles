{ config, lib, ... }:

let
  # Requires --impure build
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isDarwin isLinux;

  inherit (builtins) map attrNames readDir;
  inherit (lib) filterAttrs hasSuffix;

  configs = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));
in
{
  imports = configs;

  home-manager.users.${config.my.username} = { config, pkgs, ... }: {
    home.sessionVariables = {
      EDITOR = "${config.programs.neovim.package}/bin/nvim";
      LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen";
    };

    home.packages = with pkgs; [
      jq                           # cli to extract data out of json input
      hexyl

      # Essentials
      vscodium

      # Programming
      clang
      python3
      gnumake
      powershell
      tig

      wget curl aria
      lsof
      nmap telnet tcpdump dnsutils mtr
      git rsync
      exa fd fzf ripgrep hexyl tree bc bat
      htop ctop ytop
      alacritty
      docker-compose
    ] ++ (lib.optionals isLinux [
      # These packages do not build on Darwin
      jetbrains.idea-community
      insomnia
      traceroute
    ]);

    # Preview directory content and find directory to `cd` to
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # ctrl-t, ctrl-r, kill <tab><tab>
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = ''${pkgs.fd}/bin/fd --follow --type f --exclude="'.git'" .'';
      defaultOptions = [ "--exact" "--cycle" "--layout=reverse" ];
      # enableFishIntegration = true;
    };

    programs.mcfly = {
      enable = true;
      enableFishIntegration = true;
    };

    # Program prompt
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}

