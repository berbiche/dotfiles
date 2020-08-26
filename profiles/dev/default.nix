{ config, lib, ... }:

let
  # Requires --impure build
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isDarwin isLinux;
in
{
  imports = [ ./zsh.nix ];

  home-manager.users.${config.my.username} = { pkgs, ... }: {
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
      enableFishIntegration = true;
    };

    # Program prompt
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
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

