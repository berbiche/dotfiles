{ config, lib, pkgs, ... }:

let
  buildVs = ref:
    pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = builtins.removeAttrs ref [ "license" ];
      meta = lib.optionalAttrs (ref.license or null != null) { inherit (ref) license; };
    };

  # Replaces VSCodium's open-vsx with Microsoft's extension gallery
  # This is temporary
  extensionsGallery = builtins.toJSON {
    serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery";
    itemUrl = "https://marketplace.visualstudio.com/items";
  };
  vscodium = pkgs.vscodium.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.jq ];
    installPhase = old.installPhase or "" + ''
      #FILE=$out/lib/vscode/resources/app/product.json
      FILE=$(find $out -name 'product.json' -print -quit)
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

  my-vscode-packages = {
    editorconfig = buildVs {
      name = "editorconfig";
      publisher = "editorconfig";
      version = "0.15.1";
      sha256 = "TaovxmPt+PLsdkWDpUgLx+vRE+QRwcCtoAFZFWxLIaM=";
    };
    erlang = buildVs {
      name = "erlang";
      publisher = "pgourlain";
      version = "0.6.5";
      sha256 = "B5xLx6pI2jL7zMmeP+NqmXZ0HNkTLSxHlf9YcOD0RvM=";
    };
    firefox-dev-tools = buildVs {
      name = "vscode-firefox-debug";
      publisher = "firefox-devtools";
      version = "2.9.1";
      sha256 = "ryAAgXeqwHVYpUVlBTJDxyIXwdakA0ZnVYyKNk36Ifc=";
    };
    java = buildVs {
      name = "java";
      publisher = "redhat";
      version = "0.70.0";
      sha256 = "U1314bagDJO2houMyffq76qvaOdriEbR3npjugnzILg=";
    };
    java-debugger = buildVs {
      name = "vscode-java-debug";
      publisher = "vscjava";
      version = "0.29.0";
      sha256 = "xOPbJyXAqoEsKIBjkCqhguufbh+wZRgOM1MJ6t0p/4Q=";
    };
    nix-env-selector = buildVs {
      name = "nix-env-selector";
      publisher = "arrterian";
      version = "0.1.2";
      sha256 = "aTNxr1saUaN9I82UYCDsQvH9UBWjue/BSnUmMQOnsdg=";
    };
  };

in
{
  my.home = { config, ... }: {
    home.packages = [ vscodium ];

    programs.vscode = {
      enable = true;
      package = vscodium;

      extensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
        redhat.vscode-yaml
        ms-vscode-remote.remote-ssh
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vscode-remote.remote-ssh
        vscodevim.vim
        xaver.clang-format
        WakaTime.vscode-wakatime
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        ms-vsliveshare.vsliveshare
        ms-python.python
        llvm-org.lldb-vscode
      ]
      ++ lib.attrValues my-vscode-packages;

      userSettings = {
        "editor.cursorSmoothCaretAnimation" = true;
        "editor.fontFamily" = "'Source Code Pro', 'Anonymous Pro', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
        "editor.fontSize" = 15;
        "editor.rulers" = [ 80 100 120 ];
        "editor.smoothScrolling" = true;
        "editor.stablePeek" = true;
        "explorer.autoReveal" = false;
        "extensions.autoCheckUpdates" = false;
        "git.suggestSmartCommit" = false;
        "search.collapseResults" = "alwaysCollapse";
        "update.mode" = "none";
        "update.channel" = "none";
        "window.menuBarVisibility" = "toggle";
        "window.restoreWindows" = "none";
        "window.title" = "\${activeEditorShort}\${separator}\${rootName}\${separator}\${appName}";
        "workbench.activityBar.visible" = false;
        "workbench.colorTheme" = "Monokai Dimmed";
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.showTabs" = true;
        "workbench.editor.tabCloseButton" = "off";
        "workbench.editor.untitled.labelFormat" = "name";
        "workbench.list.smoothScrolling" = true;

        # Extension settings
        "java.semanticHighlighting.enabled" = true;
        "vscode-neovim.neovimExecutablePaths.linux" = "${config.programs.neovim.finalPackage}";

        # Language settings
        "[nix]"."editor.tabSize" = 2;
      };

      keybindings = [

      ];
    };
  };
}
