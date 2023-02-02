{ pkgs, lib, isLinux, isDarwin, ... }:

{
  config = lib.mkMerge [
    {
      my.home.imports = [ ./home-manager.nix ];
    }
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
