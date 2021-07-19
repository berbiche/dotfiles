{ config, lib, pkgs, ... }:

let
  # grammars = let
  #   tree-sitter-grammars = [
  #     "bash"
  #     "c"
  #     "cpp"
  #     "css"
  #     "go"
  #     "json"
  #     "html"
  #     "markdown"
  #     "nix"
  #     "python"
  #     "toml"
  #     "yaml"
  #   ];
  #   grammar = x: {
  #     name = "nvim/parser/${x}.so";
  #     value.source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${x}"}/parser";
  #   };
  # in lib.listToAttrs (map grammar tree-sitter-grammars);
  grammars = { };
in
{
  xdg.configFile = grammars // {
    # Stolen from L3afMe's dotnix
    "nvim/after/queries/nix/injections.scm".text = ''
      ((app [
          ((identifier) @_func)
          (select (identifier) (attrpath (attr_identifier) @_func . ))
        ]) (indented_string) @bash
          (#match? @_func "(writeShellScript(Bin)?)"))

      ; #!/bin/sh shebang highlighting
      ((indented_string) @bash @_code
        (#lua-match? @_code "\s*#!\s*/bin/sh"))

      ; Bash strings
      ((indented_string) @bash @_code
        (#lua-match? @_code "\s*## Syntax: bash"))
      ((indented_string) @bash @_code
        (#lua-match? @_code "\s*## Syntax: sh"))

      ; Lua strings
      ((indented_string) @lua @_code
        (#lua-match? @_code "\s*\\-\\- Syntax: lua"))
    '';
  };
}
