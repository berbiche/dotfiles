{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    evince thunderbird libreoffice rofi
  ];
}
