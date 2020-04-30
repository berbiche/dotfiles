{ config, pkgs, ... }:

{
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
    pavucontrol

    bitwarden bitwarden-cli
    jq                                             # cli to extract data out of json input
    #kanshi                                         # sway output management
    neofetch

    # 
    dex                                            # execute .desktop files
    gnome3.gnome_themes_standard
    #gnome3.gnome_keyring
    gnome3.nautilus
    gnome3.networkmanager-openconnect
    gnome3.rhythmbox
    slack-term
    riot-desktop
    plex-media-player
    spotify
    pamixer

    vscode
    jetbrains.idea-community

    # Entertainment
    youtube-dl
    mpv-with-scripts

    # Programming
    #rustc
    clang
    #llvmPackages.bintools
    rustup
    python3
    stack
    gnumake
    powershell

    # TUIs
    tig            # GIT
    ncdu           # File usage

    
    # Programming tools
    ###################
    # Cloud services
    travis
    heroku
    # Postman alternative
    insomnia

    # For those rare times
    chromium
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
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  # Cool text editor
  #programs.kakoune.enable = true;

  # Advanced less
  programs.lesspipe.enable = false;

  # Text-editor
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
  };

  # Program prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
