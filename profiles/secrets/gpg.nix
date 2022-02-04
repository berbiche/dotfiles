{ pkgs, lib, isLinux, ... }:

{
  config = lib.mkMerge [
    {
      my.home.imports = [ ./home-manager.nix ];
    }
    (lib.optionalAttrs isLinux {
      # Pinentry configuration for gpg-agent with pinentry-gnome3
      services.dbus.packages = [ pkgs.gcr ];
    })
  ];
}
