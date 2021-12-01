{ config, pkgs, lib, isLinux, ... }:

let
  wallpaperImage = toString config.programs.swaylock.imagePath;
in
lib.optionalAttrs isLinux {
  # Image Viewer that I only plan on using to set my wallpaper
  home.packages = [ pkgs.imv ];

  # https://old.reddit.com/r/swaywm/comments/auxspz/how_to_change_your_wallpaper_on_the_fly/
  xdg.configFile."imv/config".text = ''
    [binds]
    <Shift+W> = exec ln -sf "$imv_current_file" ${wallpaperImage} && swaymsg output "*" background ${wallpaperImage} fit

    h = prev
    l = next
    j = zoom -1
    k = zoom 1

    o = overlay
  '';
}
