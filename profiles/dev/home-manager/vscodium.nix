moduleArgs@{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isAarch64 isDarwin isLinux;

  # Replaces VSCodium's open-vsx with Microsoft's extension gallery
  # This is temporary
  extensionsGallery = builtins.toJSON {
    serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery";
    itemUrl = "https://marketplace.visualstudio.com/items";
  };
  vscodium = pkgs.vscodium.overrideAttrs(drv: {
    nativeBuildInputs = drv.nativeBuildInputs or [ ] ++ [ pkgs.jq ];
    postPatch = drv.postPatch or "" + ''
      #FILE=$out/lib/vscode/resources/app/product.json
      FILE=$(find . -name 'product.json' -print -quit)
      [ -z "$FILE" ] && { echo "Could not find product.json"; exit 1; }
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

  extensions = with pkgs.vscode-extensions; [
    asvetliakov.vscode-neovim
    bbenoist.nix
    redhat.vscode-yaml
    arrterian.nix-env-selector
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-vscode-remote.remote-ssh
    redhat.java
    # dbaeumer.vscode-eslint
    davidanson.vscode-markdownlint
    # PDF preview using PDF.js
    tomoki1207.pdf

    # My packages
    berbiche.editorconfig
    berbiche.erlang
    berbiche.firefox-debugger
    berbiche.java-debugger
  ]
  ++ lib.optionals isLinux [
    ms-vsliveshare.vsliveshare
    ms-python.python
    llvm-org.lldb-vscode
    llvm-vs-code-extensions.vscode-clangd
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") [
    xaver.clang-format
  ]
  ++ lib.optional (config.profiles.dev.wakatime.enable) berbiche.wakatime;

  package = vscodium;
  # package = pkgs.vscode;

  finalPackage =
    (pkgs.vscode-with-extensions.override {
      vscode = package;
      vscodeExtensions = extensions;
    }).overrideAttrs (drv: {
      inherit (package) pname version;
    });
in
{
  programs.vscode = lib.mkIf (!(isDarwin && isAarch64)) {
    enable = true;

    package = finalPackage;

    extensions = [];

    userSettings = {
      "editor.bracketPairColorization.enabled" = true;
      "editor.cursorSmoothCaretAnimation" = true;
      "editor.fontFamily" = "'Source Code Pro', 'Anonymous Pro', 'Droid Sans Mono', monospace, 'Droid Sans Fallback'";
      "editor.fontSize" = 15;
      "editor.guides.bracketPairs" = true;
      "editor.rulers" = [ 80 100 120 ];
      "editor.smoothScrolling" = true;
      "editor.stablePeek" = true;
      "editor.wordWrap" = "on";
      "explorer.autoReveal" = false;
      "extensions.autoCheckUpdates" = false;
      "git.suggestSmartCommit" = false;
      "search.collapseResults" = "alwaysCollapse";
      "terminal.integrated.tabs.enabled" = true;
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
      "vscode-neovim.neovimExecutablePaths.linux" = "${config.programs.neovim.finalPackage}/bin/nvim";

      # Language settings
      "[nix]"."editor.tabSize" = 2;
      "[c]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
    };

    keybindings = [

    ];
  };

  xdg.mimeApps = let
    desktopFile =
      if finalPackage.pname == "vscodium"
      then "${finalPackage}/share/codium.desktop"
      else "${finalPackage}/share/code.desktop";
  in lib.mkIf isLinux {
    defaultApplications = {
      "x-scheme-handler/vscodium" = [ desktopFile ];
      "x-scheme-handler/vscode" = [ desktopFile ];
      "x-scheme-handler/code-url-handler" = [ desktopFile ];
    };
    associations.added = {
      "x-scheme-handler/vscodium" = [ desktopFile ];
      "x-scheme-handler/vscode" = [ desktopFile ];
      "x-scheme-handler/code-url-handler" = [ desktopFile ];
    };
  };
}
