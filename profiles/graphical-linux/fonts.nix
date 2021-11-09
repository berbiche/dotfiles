{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      ubuntu_font_family
      google-fonts
      liberation_ttf
      hasklig
      powerline-fonts
      ttf_bitstream_vera
    ];

    fontconfig = {
      enable = true;
      hinting.enable = true;
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };
}
