{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.wlogoutbar ];

  xdg.configFile."wlogoutbar/style.css".text = ''
    /* @define-color my_color #393939; */
    @define-color my_color #212121;

    window {
      background: alpha(lighter(@my_color), 0.9);
    }

    #inner-box {
      padding: 10px;
      background: @my_color;
    }

    button {
      -gtk-outline-top-left-radius: 0px;
      -gtk-outline-top-right-radius: 0px;
      -gtk-outline-bottom-left-radius: 0px;
      -gtk-outline-bottom-right-radius: 0px;
      border-radius: 0px;
      margin: 2px;
      padding: 15px;
      background: @my_color;
    }

    button:selected, button:hover, button:focus {
      /* background: @theme_selected_bg_color; */
      background: rgba(255, 255, 255, 0.2);
    }

    label {
      color: white;
      box-shadow: none;
    }
  '';
}
