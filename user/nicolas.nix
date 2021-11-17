{ config, lib, pkgs, isLinux, isDarwin, ... }:

let
  inherit (config.my) username;
in
lib.mkMerge [
  {
    my.location = {
      latitude = 45.50;
      longitude = 73.56;
    };

    # my.darkTheme = "Adwaita-dark";
    # my.lightTheme = "Adwaita";

    # pkgs.numix-gtk-theme
    # pkgs.arc-theme
    # pkgs.yaru-theme
    my.theme.package = pkgs.materia-theme;
    # my.theme.dark = "Arc-Dark";
    # my.theme.light = "Arc";
    my.theme.dark = "Materia-dark-compact";
    my.theme.light = "Materia-light-compact";

    my.home = { ... }: {
      my.identity = {
        name = "Nicolas Berbiche";
        email = "nicolas@normie.dev";
        # My GPG signing key
        gpgSigningKey = "1D0261F6BCA46C6E";
      };

      # HomeManager config
      # `man 5 home-configuration.nix`
      manual.manpages.enable = true;

      fonts.fontconfig.enable = lib.mkForce true;
    };
  }

  (lib.optionalAttrs isLinux {
    users.users.${username} = {
      createHome = true;
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
      group = username;
      home = "/home/${username}";
      extraGroups = [ "wheel" "networkmanager" "input" "audio" "video" "dialout" ]
        ++ (lib.optional config.virtualisation.docker.enable "docker")
        ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
        ;
      initialPassword = username;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXqBarGejSu6/XzblEbsWocVCIyPxuQUCVLnMtnfrvi"
      ];
    };
    users.groups.${username} = {
      gid = config.users.users.${username}.uid;
    };

    # qt5 = {
    #   enable = true;
    #   platformTheme = "gtk";
    #   style = "gtk2";
    # };

    my.home = { config, pkgs, inputs, ... }: {
      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.gnome.adwaita-icon-theme;
        };
        theme = {
          # name = "Adwaita";
          name = config.my.theme.light;
          package = config.my.theme.package;
        };
        gtk2.extraConfig = ''
          gtk-cursor-theme-name="Adwaita"
          gtk-cursor-theme-size="24"
        '';
        gtk3.extraConfig = {
          "gtk-cursor-theme-name" = "Adwaita";
          "gtk-cursor-theme-size" = 24;
        };
      };
      xsession.pointerCursor = {
        package = pkgs.gnome3.gnome-themes-extra;
        name = "Adwaita";
        size = 24;
      };
      xsession.preferStatusNotifierItems = true;

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = {
          # name = "Adwaita";
          name = "gtk2";
          package = config.gtk.theme.package;
          # package = pkgs.adwaita-qt;
        };
      };

      xdg.userDirs = {
        enable = true;
        extraConfig = {
          "XDG_SCREENSHOTS_DIR" = "${config.xdg.userDirs.pictures}/screenshots";
        };
      };

      # Passwords and stuff
      # Disabled: https://github.com/nix-community/home-manager/issues/1454
      services.gnome-keyring.enable = true;
      services.gnome-keyring.components = [ "secrets" "ssh" ];

      # Make sure to open the right port range
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;

      services.blueman-applet.enable = true;
      systemd.user.services.blueman-applet = {
        Unit.After = lib.mkForce [ "graphical-session-pre.target" ];
      };
      # Started with libindicator if `xsession.preferStatusNotifierItems = true`
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet = {
        Unit.After = lib.mkForce [ "graphical-session-pre.target" ];
      };

      # Playerctl smart daemon to stop the "last player"
      # supposedly smarter than the default play-pause behavior
      # Disabled (2021-08-09) because it's not possible to ignore certain players (e.g. Firefox)
      services.playerctld.enable = false;

      home.packages = [
        pkgs.thunderbird

        # Force Zoom to run on X11 for all the popups and everything
        (pkgs.zoom-us.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
          postFixup = old.postFixup or "" + ''
            wrapProgram $out/bin/zoom --set QT_QPA_PLATFORM xcb
          '';
        }))
        # Temporary
        # (import inputs.master { inherit (pkgs) config system; }).discord
        pkgs.discord
        pkgs.teams

        # From my overlays
        pkgs.cheminot-ets
      ];

      # Copy the scripts folder
      home.file."scripts".source = let
        path = lib.makeBinPath (with pkgs; [
          gawk gnused jq wget
          pulseaudio # for pactl
          pamixer # volume control
          avizo # show a popup notification for the volume level
          sway # for swaymsg
          wl-clipboard # wl-copy/wl-paste
          fzf # menu
          wofi # menu
          xdg-user-dirs # for the screenshot tool
          networkmanager # for nmcli
          notify-send_sh # from my overlays
          playerctl # to control mpris players
          util-linux # flock
        ]);
      in "${
        # For the patchShebang phase
        pkgs.runCommandLocal "sway-scripts" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          cp --no-preserve=mode -T -r "${./scripts}" $out
          chmod +x $out/*
          for i in $out/*; do
            wrapProgram $i --prefix PATH : ${path}
          done
        ''
      }";
      lib.my = {
        getScript = name: "${config.home.file."scripts".source}/${name}";
      };

    };
  })
  # </isLinux>
]
