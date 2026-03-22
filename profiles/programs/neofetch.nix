{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "display": {
        "separator": " -> ",
        "key": {
          "width": 14
        }
      },
      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "terminal",
        "terminalfont",
        "cpu",
        "gpu",
        "memory",
        "battery",
        "locale"
      ]
    }
  '';
}
