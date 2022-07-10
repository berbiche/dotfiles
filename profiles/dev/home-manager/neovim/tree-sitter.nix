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
    "nvim/after/queries/nix/injections.scm" = {
      text = (lib.optionalString true ''
        ;; This uses oxalica's injections with the new syntax from tree sitter
        (binding
          attrpath: ((attrpath (identifier)) @_path
            (#match? @_path "^([a-z][A-Za-z]*Phase|(pre|post)[A-Z][A-Za-z]*|(.*\\.)?script)$"))
          expression: [
            (indented_string_expression) @bash
            (if_expression (indented_string_expression) @bash)
            (let_expression body: (indented_string_expression) @bash)

            ; Rough match over `lib.optionalString '''bar'''`
            (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)

            ; Rough match inner expressions concatenated with `+`
            (binary_expression [
              (indented_string_expression) @bash
              (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
              (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
              (binary_expression [
                (indented_string_expression) @bash
                (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
                (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
                (binary_expression [
                  (indented_string_expression) @bash
                  (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
                  (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
                  (binary_expression [
                    (indented_string_expression) @bash
                    (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
                    (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)])])])])])

        ; Trivial builders

        ; FIXME: Write them together with `[]` will cause lua error.
        (apply_expression
          function: (apply_expression
            function: ((_) @_func
              (#match? @_func "(^|\\.)writeShellScript(Bin)?$")))
          argument: (indented_string_expression) @bash)
        (apply_expression
          (apply_expression
            function: (apply_expression
              function: ((_) @_func
                (#match? @_func "(^|\\.)runCommand(CC|NoCC|Local|NoCCLocal)?$"))))
          argument: (indented_string_expression) @bash)

        ; Manually marked with an indicator comment
        ; FIXME: Cannot dynamic inject before `#offset!` issue being resolved.
        ; See: https://github.com/neovim/neovim/issues/16032

        ; Using `#set!` inside `[]` doesn't work, so we need to split these queries.
        (
          ((comment) @_language (#any-of? @_language "# bash" "/* bash */") (#set! "language" "bash")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# fish" "/* fish */") (#set! "language" "fish")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# vim" "/* vim */") (#set! "language" "vim")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# tmux" "/* tmux */") (#set! "language" "tmux")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# toml" "/* toml */") (#set! "language" "toml")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# yaml" "/* yaml */") (#set! "language" "yaml")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))
        (
          ((comment) @_language (#any-of? @_language "# lua" "/* lua */") (#set! "language" "lua")) .
          [
            ((indented_string_expression) @content)
            (binding
              expression: [
                (indented_string_expression) @content
                (binary_expression (indented_string_expression) @content)
                (apply_expression argument: (indented_string_expression) @content)])]
          (#offset! @content 0 2 0 -2))

        ; Reverse inject interpolation to override other injected languages.
        ; I cannot find other way to correctly highlight interpolations inside injected string.
        ; Related: https://github.com/nvim-treesitter/nvim-treesitter/issues/1688
        (interpolation
          expression: (_) @nix)

        (comment) @comment


        ; Original query modified to support the breaking changes in the syntax
        ((apply_expression [
            ((variable_expression (identifier)) @_func)
            (select_expression
              (variable_expression (identifier)) (attrpath attr: (identifier) @_func .))
          ]) [(indented_string_expression) (string_expression)] @bash
            (#match? @_func "(writeShellScript(Bin)?)"))
        ((apply_expression argument: [
            ((variable_expression (identifier)) @_func)
            (select_expression
              (variable_expression (identifier)) (attrpath attr: (identifier) @_func .))
          ]) [(indented_string_expression) (string_expression)] @bash
            (#match? @_func "(^|\\.)writeShellScript(Bin)?$"))
        ((apply_expression argument: [
            ((variable_expression (identifier)) @_func)
            (select_expression
              (variable_expression (identifier)) (attrpath attr: (identifier) @_func .))
          ]) [(indented_string_expression) (string_expression)] @bash
            (#match? @_func "writeShellScript(Bin)?"))

        ; #!/bin/sh shebang highlighting
        ([(indented_string_expression) (string_expression)] @bash @_code
          (#lua-match? @_code "\s*#!\s*/bin/sh"))

        ; Bash strings
        ([(indented_string_expression) (string_expression)] @bash @_code
          (#lua-match? @_code "\s*## Syntax: bash"))
        ([(indented_string_expression) (string_expression)] @bash @_code
          (#lua-match? @_code "\s*## Syntax: sh"))

        ; Lua strings
        ([(indented_string_expression) (string_expression)] @lua @_code
          (#lua-match? @_code "\s*\\-\\- Syntax: lua"))
      '') +
      (lib.optionalString false ''
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
        '');
    };
  };
}
