{ config, pkgs, ... }:

let
  url = "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball url));
in
{
  nixpkgs.overlays = [ waylandOverlay ];

  imports = [
    ./systemd.nix
    ./k8s.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
  };

  home.packages = with pkgs; [
    # bitwarden bitwarden-cli
    #dex                                            # execute .desktop files
    #jq                                             # cli to extract data out of json input
    #kanshi                                         # sway output management
    # neovim
    # neofetch

    # 
    gnome3.gnome_themes_standard
    #gnome3.gnome_keyring
    gnome3.nautilus
    gnome3.networkmanager-openconnect
    gnome3.rhythmbox
    slack-term
    riot-desktop
    plex-media-player

    vscode

    # Entertainment
    youtube-dl
    mpv-with-scripts

    # Programming
    #rustc
    clang
    llvmPackages.bintools
    rustup
    python3

    # Git TUI
    tig

    
    # Programming tools
    ###################
    # Cloud services
    travis
    heroku
    # Postman alternative
    insomnia
  ];


  fonts.fontconfig.enable = true;

  xdg.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.gnome3.gnome_themes_standard;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  services.blueman-applet.enable = true;
  services.gnome-keyring.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;
  #services.network-manager-applet.enable = true;

  #programs.zsh.ohMyZsh.theme = 'powerlevel10k/powerlevel10k';
  programs.zsh = {
    dotDir = ".config/zsh";
    history.share = false;
    history.expireDuplicatesFirst = true;
  };

  # Preview directory content and find directory to `cd` to
  programs.broot.enable = true;

  # Cool text editor
  #programs.kakoune.enable = true;

  # Advanced less
  programs.lesspipe.enable = true;

  # Text-editor
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
  };

  # Program prompt
  programs.starship = {
    enable = true;
  };

  # 
  programs.tmux = {
    enable = true;
    shortcut = "a";
    terminal = "screen-256color";

    clock24 = true;

    escapeTime = 0;

    newSession = true;
    secureSocket = true;

    sensibleOnTop = true;

    plugins = with pkgs; [
      tmuxPlugins.cpu
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
  };
}
