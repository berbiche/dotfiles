{ config, lib, pkgs, isLinux, isDarwin, ... }:

let
  inherit (config.my) username;
in
lib.mkMerge [
  {
    my.location = {
      latitude = 45.508;
      longitude = -73.597;
    };

    my.home = { config, ... }: {
      my.identity = {
        name = "Nicolas Berbiche";
        email = "nicolas@normie.dev";
        gpgSigningKey = "1D0261F6BCA46C6E";
      };

      my.defaults.terminal = "${config.programs.alacritty.package}/bin/alacritty";
      # my.defaults.terminal = "${config.programs.kitty.package}/bin/kitty";
      my.defaults.file-explorer = lib.mkIf isLinux "${pkgs.cinnamon.nemo}/bin/nemo";

      # pkgs.numix-gtk-theme
      # pkgs.arc-theme
      # pkgs.yaru-theme
      my.theme.package = pkgs.materia-theme;
      # my.theme.dark = "Arc-Dark";
      # my.theme.light = "Arc";
      my.theme.dark = "Materia-dark-compact";
      my.theme.light = "Materia-light-compact";
      my.theme.cursor.name = "Adwaita";
      my.theme.cursor.size = 24;

      my.terminal.fontSize = 12.0;
      my.terminal.fontName = lib.mkMerge [
        (lib.mkIf isDarwin "Menlo")
        (lib.mkIf (!isDarwin) "MesloLGS Nerd Font Mono")
      ];

      my.colors = {
        color0 = "#1d1f21";
        color1 = "#282a2e";
        color2 = "#373b41";
        color3 = "#969896";
        color4 = "#b4b7b4";
        color5 = "#c5c8c6";
        color6 = "#e0e0e0";
        color7 = "#ffffff";
        color8 = "#cc6666";
        color9 = "#de935f";
        color9Darker = "#ba7c50";
        colorA = "#f0c674";
        colorB = "#b5bd68";
        colorC = "#8abeb7";
        colorD = "#81a2be";
        colorE = "#b294bb";
        colorF = "#a3685a";
        color11 = "#5294E2";
        color12 = "#08052B";
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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6jrY1lhogYVDj73Nzr0aXROokQ2MxsgFzqrLIfO/VffBE78GdAOs2MiYD/EYPoG5azxblujH1Nd18ohShuW6GHGsHaX8/i6lg92Ukxp8aAzdiSZSoJz6UjY9JIAquMHx4wQLuVj7TzaQ6r3UFFCzQT3zVoD1xOo1Ajww5WCUp7sYu80htEPbDoPVfjWv7PJAIibVZatV8S6mlsXoIYDoTXD2uxMe6rlWsTeYWyIocg5SBqc0dsvkOx+ga1XcKHOBSjH31osQO7FRz7jhUC69IPr++ZSfHitG25CEVyhkStF5ZZ1cuo5I0gLTgaWXreF0kjcnUtqF0KViRfeBDB9Rbhv/k816WkVLBNEsy/Bw9Ly2eDYLmdBmdp91AropRvOaMDHtjBxn3Z+4WcA+PL9rcGtwPBwFHTD3RUJcpOmo8aR58xm7usLrwIn7Ulg+kEqTll+fuhpOmyCjC6K8/uPdRconJG+eGPMpYl5Oezz0a6gX7onugw9iQkMc9cTom2RmXLrGkPEPT1ARRRxsgYqFycoyuVP2vF19HzqI1y26CTf/zKrt9q2G95NVP1Pcx1yHlpfqwnWktih+iND5INrffXiKiFWVXTrkPZY99mcM1tkQ80cDff5q4xtQLDC/yO8iVSp1mY7T+J4tpA6FrCUk2FTT5yVIf6o1d4oJPwZxr4Q== cardno:000604239741"
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
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
        theme = {
          # name = "Adwaita";
          name = config.my.theme.light;
          package = config.my.theme.package;
        };
        gtk2.extraConfig = ''
          gtk-cursor-theme-name="${config.my.theme.cursor.name}"
          gtk-cursor-theme-size=${toString config.my.theme.cursor.size}
        '';
        gtk3.extraConfig = {
          "gtk-cursor-theme-name" = "${config.my.theme.cursor.name}";
          "gtk-cursor-theme-size" = config.my.theme.cursor.size;
        };
      };
      xsession.pointerCursor = {
        package = pkgs.gnome3.gnome-themes-extra;
        name = "${config.my.theme.cursor.name}";
        size = config.my.theme.cursor.size;
      };
      xsession.preferStatusNotifierItems = true;

      qt = {
        enable = true;
        platformTheme = "gtk";
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
      services.gnome-keyring.enable = true;
      # I use gpg-agent for ssh and gpg, so only use it for secrets
      services.gnome-keyring.components = [ "secrets" ];

      # Make sure to open the right port range
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;

      services.blueman-applet.enable = true;
      # Started with libindicator if `xsession.preferStatusNotifierItems = true`
      services.network-manager-applet.enable = true;

      services.plex-mpv-shim.enable = true;

      # Playerctl smart daemon to stop the "last player"
      # supposedly smarter than the default play-pause behavior
      # Disabled (2021-08-09) because it's not possible to ignore certain players (e.g. Firefox)
      services.playerctld.enable = false;

      home.packages = [
        pkgs.thunderbird

        # pkgs.pantheon.elementary-files
        # pkgs.pantheon.elementary-icon-theme
        pkgs.pantheon.elementary-music

        # Temporary
        pkgs.zoom-us
        pkgs.discord
        pkgs.teams

        # From my overlays
        pkgs.cheminot-ets
      ];

      # Copy the scripts folder
      home.file."scripts".source = let
        path = lib.makeBinPath (with pkgs; [
          gawk gnused jq wget bc
          pulseaudio # for pactl
          pamixer # volume control
          avizo # show a popup notification for the volume level
          sway # for swaymsg
          flameshot
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
          mkdir -p "$out"/bin
          cp --no-preserve=mode -T -r "${./scripts}" "$out"/_bin
          chmod +x "$out"/_bin/*
          for i in "$out"/_bin/*; do
            makeWrapper "$i" "$out"/bin/"$(basename $i)" --prefix PATH : ${path}
          done
        ''
      }/bin";
      lib.my = {
        # Instead of using the path in the nix store, return the relative path of the script in my configuration
        # This makes it possible to update scripts without reloading my Sway configuration
        getScript = name:
          assert lib.assertMsg (builtins.pathExists (./scripts + "/${name}"))
            "The specified script '${name}' does not exist in the 'scripts/' folder";
          "${config.home.homeDirectory}/${config.home.file."scripts".target}/${name}";
      };

    };
  })
  # </isLinux>
]
