{ config, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/pull/86480
{
  environment.systemPackages = with pkgs; [
    (steam.override {
      extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ];
      # Broken
      # nativeOnly = true;
    })
  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;
}
