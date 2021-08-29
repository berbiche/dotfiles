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

    home.file.".mailcap".text = ''
    '';
  };
}
