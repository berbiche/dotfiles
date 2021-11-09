{ ... }:

{
  my.home = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      pavucontrol # Audio software
      playerctl # control MPRIS players
      libnotify # `notify-send` notifications to test mako
      dex # execute .desktop files

      ffmpeg

      glib.bin # for 'gio'

      # Programs
      #gnome3.nautilus # Gnome file manager
      cinnamon.nemo # Cinnamon's fork of Gnome's file manager
      gnome3.networkmanager-openconnect # OpenConnect plugin for NetworkManager
      gnome3.rhythmbox # Gnome music player
      gnome3.eog # Gnome image viewer
      gnome3.seahorse # Gnome Keyring secret management

      # Virtualization software
      gnome3.gnome-boxes
      virt-manager
      vagrant

      # Torrent client
      qbittorrent

      # Minecraft client
      multimc

      # Merge pdfs and other stuff
      pdfarranger

      # Companion for the fxcast firefox extension
      # How to use: `fx_cast_bridge -p 9556 -d`
      fx_cast_bridge
    ];


    # XDG configuration
    xdg.configFile."mimeapps.list".force = true;
    xdg.enable = true;
    xdg.mimeApps = rec {
      enable = true;

      # defaultApplications = lib.mapAttrs (_n: v: lib.head v) config.xdg.mimeApps.associations.added;
      defaultApplications = config.xdg.mimeApps.associations.added;

      associations.added = {
        "inode/directory"               = [ "nemo.desktop" ];
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
