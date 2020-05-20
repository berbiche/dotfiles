{ config, pkgs, ... }:

{
  home.stateVersion = "19.09";

  imports = [
    ./systemd.nix
    ./k8s.nix
    ./gpg.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
    # Fix Firefox. See <https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/>
    MOZ_DBUS_REMOTE = 1;
  };

  home.packages = with pkgs; [
    pavucontrol

    bitwarden bitwarden-cli
    jq                                             # cli to extract data out of json input
    #kanshi                                         # sway output management
    neofetch
    libnotify

    # 
    dex                                            # execute .desktop files
    gnome3.gnome_themes_standard
    #gnome3.gnome_keyring
    gnome3.nautilus
    gnome3.networkmanager-openconnect
    gnome3.rhythmbox
    riot-desktop
    spotify
    pamixer
    discord                                        # unfortunately

    gnome3.gnome-boxes
    virt-manager

    # For those rare times
    chromium

    # Essentials
    vscode
    jetbrains.idea-community

    # Entertainment
    youtube-dl
    mpv-with-scripts

    # Programming
    #llvmPackages.bintools
    clang
    python3
    gnumake
    powershell
    direnv
    niv

    # TUIs
    tig            # GIT
    ncdu           # File usage

    
    # Programming tools
    ###################
    # Postman alternative
    insomnia
  ];

  # HomeManager config
  manual.manpages.enable = true;
  news.display = "silent";


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

  services.lorri.enable = true;
  services.blueman-applet.enable = true;
  services.gnome-keyring.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;
  #services.network-manager-applet.enable = true;

  # Run emacs as a service
  services.emacs.enable = true;
  programs.emacs.enable = true;

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
