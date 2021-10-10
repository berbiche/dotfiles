{ config, lib, pkgs, ... }:

with lib;

let
  topConf = config;
in
{
  imports = [ ./neomutt.nix ./accounts.nix ];

  my.home = { config, lib, ... }: let
    mbsyncCmd = "${config.programs.mbsync.package}/bin/mbsync";
  in {
    accounts.email.maildirBasePath = "${config.home.homeDirectory}/mail";

    # Local maildir
    programs.mbsync.enable = true;

    # To send emails
    programs.msmtp.enable = true;

    # Mail indexer and tagger
    programs.notmuch.enable = true;

    # Notifies mbsync of new emails
    services.imapnotify.enable = true;

    # Manages my contacts
    programs.abook.enable = true;

    # Sync emails on initial login
    systemd.user.services.mbsync-oneshot = {
      Unit = {
        Description = "mbsync oneshot synchronisation";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${mbsyncCmd} --all";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    programs.notmuch.hooks.postNew = /*pkgs.writeShellScript "imap-on-notify-post"*/ ''
      ${pkgs.notify-send_sh}/bin/notify-send.sh --icon=mail-unread --app-name=notmuch \
        "Email" "New email available in Inbox"
    '';

    # Play the msn alert sound when receiving a notification
    services.dunst.settings.incoming-mail = {
      summary = "Email";
      body = "New email*";
      script = let
        # The sound file will have to be synchronized manually because I don't think
        # I can include it in this repository due to copyrights?
        sound = ''"$(${pkgs.xdg-user-dirs}/bin/xdg-user-dir MUSIC)/msn_alert.wav"'';
      in toString (pkgs.writeShellScript "dunst-email" ''
        test -f ${sound} || exit
        ${lib.optionalString topConf.services.pipewire.enable ''
          ${pkgs.pipewire}/bin/pw-play --volume 0.8 ${sound}
        ''}
        ${lib.optionalString topConf.hardware.pulseaudio.enable ''
          ${pkgs.pulseaudio}/bin/paplay --volume 30000 ${sound}
        ''}
      '');
    };

    home.file.".mailcap".text = let
      setsid = "${pkgs.util-linux}/bin/setsid";
      openfile = "${pkgs.writeShellScript "openfile" ''
        # Helps open a file with xdg-open from mutt in a external program without weird side effects.
        tempdir="''${TMPDIR:-$(mktemp -d)}"
        file="$tempdir/$(basename "$1")"
        [ "$(uname)" = "Darwin" ] && opener="open" || opener="${setsid} -f ${pkgs.xdg_utils}/bin/xdg-open"
        mkdir -p "$tempdir"
        cp -f "$1" "$file"
        $opener "$file" >/dev/null 2>&1
        find "''${tempdir:?}" -mtime +1 -type f -delete
      ''}";
    in ''
      ${lib.optionalString false "text/html; ${pkgs.w3m}/bin/w3m -dump -T text/html -I %{charset} -O utf-8 %s; copiousoutut; description=HTML Text; nametemplate=%s.html"}


      text/plain; $EDITOR %s ;
      ${lib.optionalString true "text/html; ${openfile} %s ; nametemplate=%s.html"}
      text/html; ${pkgs.lynx}/bin/lynx -assume_charset=%{charset} -display_charset=utf-8 -dump %s; nametemplate=%s.html; copiousoutput;
      image/*; ${openfile} %s ;
      application/pdf; ${openfile} %s ;
      # application/pgp-encrypted; gpg -d '%s'; copiousoutput;
    '';
  };
}
