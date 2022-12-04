;;; init.el -*- lexical-binding: t; no-byte-compile: t; -*-

;; More information about these modules (and what flags they support) can be
;; found in modules/README.org.

(doom! :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       company
       ;;helm
       ;;ido
       ;;(ivy +icons +fuzzy)
       (vertico +icons)

       :ui
       ;;deft
       doom
       doom-dashboard
       doom-quit
       ;;(emoji +unicode)
       hl-todo
       ;;hydra
       indent-guides
       ;;minimap
       modeline
       nav-flash
       ;;neotree
       ophints
       (popup +defaults)
       ;;tabs
       treemacs
       ;;unicode
       (vc-gutter +pretty)
       vi-tilde-fringe
       ;;window-select
       workspaces
       ;;zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       ;;(format +onsave)
       format
       ;;god
       ;;lispy
       ;;multiple-cursors
       ;;objed
       ;;parinfer
       ;;rotate-text
       snippets
       ;;word-wrap

       :emacs
       dired
       electric
       ibuffer
       undo
       vc

       :term
       ;;eshell
       ;;shell
       ;;term
       vterm

       :checkers
       syntax
       (spell
        +flyspell
        +everywhere)
       ;;grammar

       :tools
       ansible
       ;;biblio
       (debugger +lsp)
       direnv
       ;;docker
       editorconfig
       ;;ein
       (eval +overlay)
       ;;gist
       lookup
       (lsp +peek)
       magit
       make
       ;;pass
       ;;pdf
       ;;prodigy
       rgb
       ;;taskrunner
       terraform
       ;;tmux
       tree-sitter
       ;;upload

       :os
       (:if IS-MAC macos)
       (tty +osc)

       :lang
       ;;agda
       (cc +lsp +tree-sitter)
       ;;clojure
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       data
       ;;(dart +flutter)
       ;;dhall
       ;;(elixir +lsp +tree-sitter)
       ;;elm
       emacs-lisp
       (erlang +lsp)
       ;;ess
       ;;factor
       ;;faust
       ;;fsharp
       ;;fstar
       ;;gdscript
       (go +lsp +tree-sitter)
       ;;(graphql +lsp)
       ;;(haskell +lsp)
       ;;hy
       ;;idris
       (json +lsp +tree-sitter)
       (java +lsp +tree-sitter)
       ;;(javascript +lsp)
       ;;julia
       ;;kotlin
       ;;latex
       ;;lean
       ;;ledger
       ;;lua
       markdown
       ;;nim
       (nix +lsp +tree-sitter)
       ;;ocaml
       (org
        +dragndrop
        ;;+hugo
        ;;+ipython
        +pandoc
        ;;+pomodoro
        +present)
       ;;php
       plantuml
       ;;purescript
       (python
        +lsp
        +pyright
        +tree-sitter)
       ;;qt
       ;;racket
       ;;raku
       ;;rest
       ;;rst
       ;;(ruby +rails)
       (rust +lsp +tree-sitter)
       ;;scala
       ;;(scheme +guile)
       (sh
        +lsp
        +fish
        +powershell
        +tree-sitter)
       ;;sml
       ;;solidity
       ;;swift
       ;;terra
       ;;web
       yaml
       (zig +lsp)

       :email
       ;;(mu4e +org +gmail)
       ;;(notmuch)
       ;;(wanderlust +gmail)

       ;; Applications are complex and opinionated modules that transform Emacs
       ;; toward a specific purpose. They may have additional dependencies and
       ;; should be loaded late.
       :app
       ;;calendar
       ;;emms
       ;;everywhere
       ;;irc
       ;;(rss +org)
       ;;twitter

       :config
       ;;literate
       (default +bindings +smartparens))

