{ config, lib, pkgs, ... }:

let
  inherit (builtins) map attrNames readDir import;
  inherit (lib) filterAttrs hasSuffix;

  # Import all programs under ./programs using their default.nix
  customPrograms = let
    files = readDir ./programs;
    filtered = filterAttrs (n: v: v == "directory" || (v == "regular" && hasSuffix ".nix" n));
  in map (p: ./. + "/programs/${p}") (attrNames (filtered files));
in
{
  imports = customPrograms;

  home.packages = with pkgs; [
    pavucontrol

    bitwarden bitwarden-cli
    jq                           # cli to extract data out of json input
    #kanshi                      # sway output management
    libnotify                    # `notify-send` notifications to test mako
    hexyl

    #
    dex # execute .desktop files
    gnome3.nautilus
    gnome3.networkmanager-openconnect
    gnome3.rhythmbox
    gnome3.eog
    gnome3.seahorse
    signal-desktop
    riot-desktop
    spotify
    pamixer # control pulse audio volume in scripts
    discord # unfortunately

    # Virtualization software
    gnome3.gnome-boxes
    # virt-manager

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
  #programs.zoxide = {
  #  enable = true;
  #  enableZshIntegration = true;
  #  # options = [ "--no-aliases" ];
  #};

  programs.swaylock = {
    enable = true;
    imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
  };


  # XDG configuration
  xdg =  {
    enable = true;
    mime.enable = false;
    mimeApps.enable = true;

    mimeApps.defaultApplications = {
      "inode/directory"               = [ "nautilus.desktop" "org.gnome.Nautilus.desktop" ];
      "x-scheme-handler/http"         = [ "firefox.desktop" ];
      "x-scheme-handler/https"        = [ "firefox.desktop" ];
      "x-scheme-handler/ftp"          = [ "firefox.desktop" ];
      "x-scheme-handler/chrome"       = [ "firefox.desktop" ];
      "text/html"                     = [ "firefox.desktop" ];
      "application/x-extension-htm"   = [ "firefox.desktop" ];
      "application/x-extension-html"  = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml"         = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht"   = [ "firefox.desktop" ];
      "x-scheme-handler/about"        = [ "firefox.desktop" ];
      "x-scheme-handler/unknown"      = [ "firefox.desktop" ];
      "x-scheme-handler/zoommtg"      = [ "Zoom.desktop" ];
      "image/jpeg"                    = [ "org.gnome.eog.desktop" ];
      "image/bmp"                     = [ "org.gnome.eog.desktop" ];
      "image/gif"                     = [ "org.gnome.eog.desktop" ];
      "image/jpg"                     = [ "org.gnome.eog.desktop" ];
      "image/pjpeg"                   = [ "org.gnome.eog.desktop" ];
      "image/png"                     = [ "org.gnome.eog.desktop" ];
      "image/tiff"                    = [ "org.gnome.eog.desktop" ];
      "image/x-bmp"                   = [ "org.gnome.eog.desktop" ];
      "image/x-gray"                  = [ "org.gnome.eog.desktop" ];
      "image/x-icb"                   = [ "org.gnome.eog.desktop" ];
      "image/x-ico"                   = [ "org.gnome.eog.desktop" ];
      "image/x-png"                   = [ "org.gnome.eog.desktop" ];
      "image/x-portable-anymap"       = [ "org.gnome.eog.desktop" ];
      "image/x-portable-bitmap"       = [ "org.gnome.eog.desktop" ];
      "image/x-portable-graymap"      = [ "org.gnome.eog.desktop" ];
      "image/x-portable-pixmap"       = [ "org.gnome.eog.desktop" ];
      "image/x-xbitmap"               = [ "org.gnome.eog.desktop" ];
      "image/x-xpixmap"               = [ "org.gnome.eog.desktop" ];
      "image/x-pcx"                   = [ "org.gnome.eog.desktop" ];
      "image/svg+xml"                 = [ "org.gnome.eog.desktop" ];
      "image/svg+xml-compressed"      = [ "org.gnome.eog.desktop" ];
      "image/vnd.wap.wbmp"            = [ "org.gnome.eog.desktop" ];
      "image/x-icns"                  = [ "org.gnome.eog.desktop" ];
      "audio/x-vorbis+ogg"            = [ "rhythmbox.desktop" ];
      "audio/vorbis"                  = [ "rhythmbox.desktop" ];
      "audio/x-vorbis"                = [ "rhythmbox.desktop" ];
      "audio/x-scpls"                 = [ "rhythmbox.desktop" ];
      "audio/x-mp3"                   = [ "rhythmbox.desktop" ];
      "audio/x-mpeg"                  = [ "rhythmbox.desktop" ];
      "audio/mpeg"                    = [ "rhythmbox.desktop" ];
      "audio/x-mpegurl"               = [ "rhythmbox.desktop" ];
      "audio/x-flac"                  = [ "rhythmbox.desktop" ];
      "audio/mp4"                     = [ "rhythmbox.desktop" ];
      "audio/x-it"                    = [ "rhythmbox.desktop" ];
      "audio/x-mod"                   = [ "rhythmbox.desktop" ];
      "audio/x-s3m"                   = [ "rhythmbox.desktop" ];
      "audio/x-stm"                   = [ "rhythmbox.desktop" ];
      "audio/x-xm"                    = [ "rhythmbox.desktop" ];
      "video/flv"                     = [ "mpv.desktop" ];
      "video/mp2t"                    = [ "mpv.desktop" ];
      "video/mp4"                     = [ "mpv.desktop" ];
      "video/mp4v-es"                 = [ "mpv.desktop" ];
      "video/mpeg"                    = [ "mpv.desktop" ];
      "video/msvideo"                 = [ "mpv.desktop" ];
      "video/ogg"                     = [ "mpv.desktop" ];
      "video/quicktime"               = [ "mpv.desktop" ];
      "video/vivo"                    = [ "mpv.desktop" ];
      "video/vnd.divx"                = [ "mpv.desktop" ];
      "video/vnd.rn-realvideo"        = [ "mpv.desktop" ];
      "video/vnd.vivo"                = [ "mpv.desktop" ];
      "video/webm"                    = [ "mpv.desktop" ];
      "video/x-anim"                  = [ "mpv.desktop" ];
      "video/x-avi"                   = [ "mpv.desktop" ];
      "video/x-flc"                   = [ "mpv.desktop" ];
      "video/x-fli"                   = [ "mpv.desktop" ];
      "video/x-flic"                  = [ "mpv.desktop" ];
      "video/x-flv"                   = [ "mpv.desktop" ];
      "video/x-m4v"                   = [ "mpv.desktop" ];
      "video/x-matroska"              = [ "mpv.desktop" ];
      "video/x-mpeg"                  = [ "mpv.desktop" ];
      "video/x-ms-asf"                = [ "mpv.desktop" ];
      "video/x-ms-asx"                = [ "mpv.desktop" ];
      "video/x-ms-wm"                 = [ "mpv.desktop" ];
      "video/x-ms-wmv"                = [ "mpv.desktop" ];
      "video/x-ms-wmx"                = [ "mpv.desktop" ];
      "video/x-ms-wvx"                = [ "mpv.desktop" ];
      "video/x-msvideo"               = [ "mpv.desktop" ];
      "video/x-nsv"                   = [ "mpv.desktop" ];
      "video/x-ogm+ogg"               = [ "mpv.desktop" ];
      "video/x-theora+ogg"            = [ "mpv.desktop" ];
    };

    mimeApps.associations.added = {
      "image/png"                     = [ "org.gnome.eog.desktop" ];
      "x-scheme-handler/http"         = [ "firefox.desktop" ];
      "x-scheme-handler/https"        = [ "firefox.desktop" ];
      "x-scheme-handler/ftp"          = [ "firefox.desktop" ];
      "x-scheme-handler/chrome"       = [ "firefox.desktop" ];
      "text/html"                     = [ "firefox.desktop" ];
      "application/x-extension-htm"   = [ "firefox.desktop" ];
      "application/x-extension-html"  = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml"         = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht"   = [ "firefox.desktop" ];
      "text/plain"                    = [ "code-url-handler.desktop" "emacs.desktop" "nvim.desktop" "org.gnome.gedit.desktop" ];
      "application/pdf"               = [ "org.gnome.Evince.desktop" "firefox.desktop" "chromium-browser.desktop" "draw.desktop" ];
      "video/x-matroska"              = [ "mpv.desktop" "org.gnome.Totem.desktop" ];
      "text/x-c++src"                 = [ "emacs.desktop" "firefox.desktop" "nvim.desktop" "org.gnome.gedit.desktop" ];
      "text/x-diff"                   = [ "emacs.desktop" "firefox.desktop" "org.gnome.gedit.desktop" ];
      "application/x-compressed-tar"  = [ "org.gnome.Nautilus.desktop" "org.gnome.FileRoller.desktop" ];
      "application/xml"               = [ "code-url-handler.desktop" ];
      "image/bmp"                     = [ "org.gnome.eog.desktop" ];
      "image/gif"                     = [ "org.gnome.eog.desktop" ];
      "image/jpg"                     = [ "org.gnome.eog.desktop" ];
      "image/pjpeg"                   = [ "org.gnome.eog.desktop" ];
      "image/tiff"                    = [ "org.gnome.eog.desktop" ];
      "image/x-bmp"                   = [ "org.gnome.eog.desktop" ];
      "image/x-gray"                  = [ "org.gnome.eog.desktop" ];
      "image/x-icb"                   = [ "org.gnome.eog.desktop" ];
      "image/x-ico"                   = [ "org.gnome.eog.desktop" ];
      "image/x-png"                   = [ "org.gnome.eog.desktop" ];
      "image/x-portable-anymap"       = [ "org.gnome.eog.desktop" ];
      "image/x-portable-bitmap"       = [ "org.gnome.eog.desktop" ];
      "image/x-portable-graymap"      = [ "org.gnome.eog.desktop" ];
      "image/x-portable-pixmap"       = [ "org.gnome.eog.desktop" ];
      "image/x-xbitmap"               = [ "org.gnome.eog.desktop" ];
      "image/x-xpixmap"               = [ "org.gnome.eog.desktop" ];
      "image/x-pcx"                   = [ "org.gnome.eog.desktop" ];
      "image/svg+xml"                 = [ "org.gnome.eog.desktop" ];
      "image/svg+xml-compressed"      = [ "org.gnome.eog.desktop" ];
      "image/vnd.wap.wbmp"            = [ "org.gnome.eog.desktop" ];
      "image/x-icns"                  = [ "org.gnome.eog.desktop" ];
      "audio/vorbis"                  = [ "rhythmbox.desktop" ];
      "audio/x-vorbis"                = [ "rhythmbox.desktop" ];
      "audio/x-scpls"                 = [ "rhythmbox.desktop" ];
      "audio/x-mp3"                   = [ "rhythmbox.desktop" ];
      "audio/x-mpeg"                  = [ "rhythmbox.desktop" ];
      "audio/mpeg"                    = [ "rhythmbox.desktop" ];
      "audio/x-mpegurl"               = [ "rhythmbox.desktop" ];
      "audio/x-flac"                  = [ "rhythmbox.desktop" ];
      "audio/mp4"                     = [ "rhythmbox.desktop" ];
      "audio/x-it"                    = [ "rhythmbox.desktop" ];
      "audio/x-mod"                   = [ "rhythmbox.desktop" ];
      "audio/x-s3m"                   = [ "rhythmbox.desktop" ];
      "audio/x-stm"                   = [ "rhythmbox.desktop" ];
      "audio/x-xm"                    = [ "rhythmbox.desktop" ];
      "audio/midi"                    = [ "mpv.desktop" ];
      "application/zip"               = [ "org.gnome.Nautilus.desktop" ];
      "video/mp4"                     = [ "firefox.desktop" "mpv.desktop" ];
    };
  };
}
