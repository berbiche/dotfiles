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
in
{
  home-manager.users.${config.my.username} = { config, ... }: {
    home.packages = [ vscodium ];

    programs.vscode = {
      enable = true;
      package = vscodium;

      extensions = with pkgs.vscode-extensions; [
        # "firefox-devtools.vscode-firefox-debug"
        # "editorconfig.editorconfig"
        # "pgourlain.erlang"
        # "redhat.java"
        # "arrterian.nix-env-selector"

        bbenoist.Nix
        redhat.vscode-yaml
        ms-vscode-remote.remote-ssh
        ms-kubernetes-tools.vscode-kubernetes-tools 
        vscodevim.vim
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        ms-python.python
        llvm-org.lldb-vscode
      ];

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
      };

      keybindings = [

      ];
    };
  };
}
