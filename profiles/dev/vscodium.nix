{ config, lib, pkgs, ... }:

let
  # Replaces VSCodium's open-vsx with Microsoft's extension gallery
  # This is temporary
  extensionsGallery = builtins.toJSON {
    serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery";
    itemUrl = "https://marketplace.visualstudio.com/items";
  };
  vscodium = pkgs.vscodium.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.jq ];
    installPhase = old.installPhase or "" + ''
      FILE=$out/lib/vscode/resources/app/product.json
      mv $FILE .
      echo "Patching product.json"
      jq <product.json >$FILE '
        with_entries(
          if .key == "extensionsGallery"
          then .value = ${extensionsGallery}
          else .
          end
        )
      '
      if [ $? -eq 0 ]; then
        echo "Patching product.json successfully"
      else
        echo "Patching product.json failed"
      fi
    '';
  });
in
{
  home-manager.users.${config.my.username} = {
    home.packages = [ vscodium ];

    programs.vscode = {
      enable = false;
      package = vscodium;

      extensions = [

      ];

      keybindings = [

      ];
    };
  };
}
