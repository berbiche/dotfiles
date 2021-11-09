{ ... }:

{
  programs.dconf.enable = true;

  my.home = { config, lib, pkgs, ... }: {
    dconf.settings = {
      # Change the default terminal for Nemo
      "org/cinnamon/desktop/applications/terminal" = {
        exec = toString (pkgs.writeShellScript "nemo-terminal" ''
          ${config.my.defaults.terminal} --class floating-term "$@"
        '');
        exec-arg = "-e";
      };
      "org/nemo/desktop".show-desktop-icons = false;
      "org/nemo/plugins".disabled-actions = [ "new-launcher.nemo_action" "change-background.nemo_action" "set-as-background.nemo_action" "add-desklets.nemo_action" ];
      "org/nemo/preferences" = {
        ignore-view-metadata = true;
        show-advanced-permissions = true;
        show-full-path-titles = true;
        show-location-entry = false;
      };
    };
  };
}
