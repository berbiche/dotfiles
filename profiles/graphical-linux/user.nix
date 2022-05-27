{ ... }:

{
  home-manager.sharedModules = [
    {
      # Allow moving alsa audio sources
      # This is useful with certain Steam games
      home.file.".alsoftrc".text = ''
        [pulse]
        allow-moves = true
      '';
      home.file.".alsoftrc".force = true;
    }
  ];

  my.home = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      # Remove journalctl noise related to assistive technologies (AT-SPI)
      at-spi2-core

      # Audio software
      pavucontrol
      # control MPRIS players
      playerctl
      # `notify-send` notifications to test mako
      libnotify
      # execute .desktop files
      dex
      # Video/Audio encoding software
      ffmpeg
      # Video player
      haruna
      # Calculator
      nasc
      # for 'gio'
      glib.bin
      #gnome3.nautilus # Gnome file manager
      cinnamon.nemo # Cinnamon's fork of Gnome's file manager
      gnome3.networkmanager-openconnect # OpenConnect plugin for NetworkManager
      rhythmbox # Gnome music player
      gnome3.eog # Gnome image viewer
      gnome3.seahorse # Gnome Keyring secret management
      # Virtualization software
      gnome3.gnome-boxes
      virt-manager
      vagrant
      # Torrent client
      qbittorrent
      transmission-remote-gtk
      # Minecraft client
      polymc
      # Merge pdfs and other stuff
      pdfarranger
      # Companion for the fxcast firefox extension
      # How to use: `fx_cast_bridge -p 9556 -d`
      # fx_cast_bridge
    ];


    # XDG configuration
    xdg.configFile."mimeapps.list".force = true;
    xdg.enable = true;
    xdg.mimeApps = rec {
      enable = true;
      # defaultApplications = lib.mapAttrs (_n: v: lib.head v) config.xdg.mimeApps.associations.added;
      defaultApplications = config.xdg.mimeApps.associations.added;
      associations.added = {
        "inode/directory"               = [ "nemo.desktop" "emacs.desktop" "codium.desktop" "nautilus.desktop" ];
        "application/pdf"               = [ "org.gnome.Evince.desktop" "firefox.desktop" ];
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
        "audio/x-vorbis+ogg"            = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/vorbis"                  = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-vorbis"                = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-scpls"                 = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-mp3"                   = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-mpeg"                  = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/mpeg"                    = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-mpegurl"               = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-flac"                  = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/mp4"                     = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-it"                    = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-mod"                   = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-s3m"                   = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-stm"                   = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "audio/x-xm"                    = [ "rhythmbox.desktop" "io.elementary.music.desktop" ];
        "video/flv"                     = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/mp2t"                    = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/mp4"                     = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/mp4v-es"                 = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/mpeg"                    = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/msvideo"                 = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/ogg"                     = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/quicktime"               = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/vivo"                    = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/vnd.divx"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/vnd.rn-realvideo"        = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/vnd.vivo"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/webm"                    = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-anim"                  = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-avi"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-flc"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-fli"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-flic"                  = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-flv"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-m4v"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-matroska"              = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-mpeg"                  = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-asf"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-asx"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-wm"                 = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-wmv"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-wmx"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ms-wvx"                = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-msvideo"               = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-nsv"                   = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-ogm+ogg"               = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "video/x-theora+ogg"            = [ "org.kde.haruna.desktop" "mpv.desktop" ];
        "x-scheme-handler/mailto"       = [ "thunderbird.desktop" ];
        "x-scheme-handler/mid"          = [ "thunderbird.desktop" ];
        "x-scheme-handler/news"         = [ "thunderbird.desktop" ];
        "x-scheme-handler/snews"        = [ "thunderbird.desktop" ];
        "x-scheme-handler/nttp"         = [ "thunderbird.desktop" ];
        "x-scheme-handler/feed"         = [ "thunderbird.desktop" ];
        "x-scheme-handler/webcal"       = [ "thunderbird.desktop" ];
        "x-scheme-handler/webcals"      = [ "thunderbird.desktop" ];
        "application/rss+xml"           = [ "thunderbird.desktop" ];
        "application/x-extension-rss"   = [ "thunderbird.desktop" ];
      };

    };

  };
}
