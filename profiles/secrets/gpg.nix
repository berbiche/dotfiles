{ pkgs, lib, isLinux, isDarwin, ... }:

{
  config = lib.mkMerge [
    (lib.optionalAttrs isLinux {
      # Pinentry configuration for gpg-agent with pinentry-gnome
      services.dbus.packages = [ pkgs.gcr ];
    })
    (lib.optionalAttrs isDarwin {
      programs.gnupg.agent.enable = true;
      programs.gnupg.agent.enableSSHSupport = true;
    })
  ];
}
