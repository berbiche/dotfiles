{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ wofi ];

  xdg.configFile."wofi/config".text = ''
    mode=run
    width=600
    height=400
    allow_images=false
    image_size=18
    prompt=Run program:
    insensitive=true
  '';

  xdg.configFile."wofi/style.css".text = ''
    @define-color --main-color   #61AFEF;
    @define-color --background   #282C34;
    @define-color --text         #808080;
    @define-color --main-color-2 #777D87;

    window {
      /* border: 2px solid var(--main-color); */
      border: 2px solid @--main-color;
      padding: 10px;
      margin: 10px;
      background-color: @--background;
      color: @--text;
    }

    #outer-box {
      padding: 10px;
      margin: 15px;
    }

    #inner-box {
      /* margin: 10px; */
      margin-top: 15px;
      margin-bottom: 0;
      color: @--text;
    }

    .entry {
      margin: 5px 0;
      height: 15px;
    }

    #input {
      background-color: @--main-color-2;
      color: @--background;
    }

    #img {
      /* border: 1px solid black; */
    }
  '';
}
