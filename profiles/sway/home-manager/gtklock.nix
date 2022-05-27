{ config, lib, pkgs, ... }:

let
  swaylockCfg = config.programs.swaylock;
in
{
  xdg.configFile."gtklock/style.css".text = ''
    @define-color bg rgb(48, 48, 48);
    @define-color text #FFF;

    * {
      color: @text;
    }

    window {
      background-color: @bg;
      background: url('file://${config.home.homeDirectory}/.background-image');
      background-size: contain;
      background-repeat: no-repeat;
      background-position: center;
    }
  '';
}
