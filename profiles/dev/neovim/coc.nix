{ pkgs, lib, ... }:

{
  xdg.configFile."nvim/coc-settings.json".source = (pkgs.formats.json { }).generate "coc-settings.json" {
    diagnostic = {
      enable = true;
      errorSign = ">>";
      warningSign = "⚠";
    };
    languageserver = {
      bash = {
        command = "bash-language-server";
        args = [ "start" ];
        filetypes = [ "sh" "bash" ];
        ignoredRootPaths = [ "~" ];
      };
      nix = {
        command = "rnix-lsp";
        filetypes = [ "nix" ];
      };
    };

    "explorer.icon.enableNerdFond" = true;
    "explorer.icon.enableVimDevicons" = true;
    "explorer.buffer.tabOnly" = true;
    "explorer.file.revealWhenOpen" = true;
    "explorer.file.autoReveal" = false;
    "explorer.file.hiddenRules" = {
      "extensions" = [
        "o" "a" "obj" "pyc"
      ];
      "filenames" = [ "node_modules" "result" "_build" ];
      "patternMatches" = [ "^\\." ];
    };
    "explorer.file.root.template" = "[icon] [title] [root] [fullpath]";
    "explorer.keyMappings.global" = {
      "u" = [ "wait" "indentPrev" ];
      "cf" = "addFile";
      "cd" = "addDirectory";
      "r" = "refresh";
      "a" = false;
      "A" = false;
      "R" = "rename";
      "/" = "search";
    };
  };
}