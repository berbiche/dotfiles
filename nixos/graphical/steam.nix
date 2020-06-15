{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (steam.override { 
      extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ];
      # Broken
      # nativeOnly = true;
    })
  ];

  nixpkgs.config.allowUnfree = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  #security.pam.loginLimits = [{
  #  domain = "*";
  #  type = "hard";
  #  item = "nofile";
  #  value = "1048576";
  #}];
}
