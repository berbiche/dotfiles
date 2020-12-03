;;; init.el -*- lexical-binding: t; -*-

;; Copy this file to ~/.doom.d/init.el or ~/.config/doom/init.el ('doom install'
;; will do this for you). The `doom!' block below controls what modules are
;; enabled and in what order they will be loaded. Remember to run 'doom refresh'
;; after modifying it.
;;
;; More information about these modules (and what flags they support) can be
;; found in modules/README.org.

(doom! :input
       ;;chinese
       ;;japanese
       ;;layout            ; auie,ctsrnm is the superior home row

       :completion
       company           ; the ultimate code completion backend
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ivy               ; a search engine for love and life

       :ui
       ;;deft              ; notational velocity for Emacs
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       doom-quit         ; DOOM quit-message prompts when you quit Emacs
       ;;(emoji +unicode)  ;
       ;;fill-column       ; a `fill-column' indicator
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       ;;hydra
       indent-guides     ; highlighted indent columns
       ligature          ; replace bits of code with pretty symbols
       ;;minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink the current line after jumping
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints           ; highlight the region an operation acts on
       (popup            ; tame sudden yet inevitable temporary windows
        +all             ; catch all popups that start with an asterix
        +defaults)       ; default popup rules
       ;;tabs              ; an tab bar for Emacs
       treemacs          ; a project drawer, like neotree but cooler
       ;;unicode           ; extended unicode support for various languages
       vc-gutter         ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       ;;zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       ;;(format +onsave)  ; automated prettiness
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who dont like vim
       ;;multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       ;;rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       ;;word-wrap         ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ibuffer           ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere 
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       spell               ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ansible
       ;;debugger          ; FIXME stepping through code, to help you add bugs
       direnv
       docker
       editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, repls)
       ;;gist              ; interacting with github gists
       lookup           ; helps you navigate your code and documentation
       lsp
       magit             ; a git porcelain for Emacs
       make              ; run make tasks from Emacs
       ;;pass              ; password manager for nerds
       ;;pdf               ; pdf enhancements
       ;;prodigy           ; FIXME managing external services & code builders
       rgb               ; creating color strings
       ;;taskrunner        ; taskrunner for all your projects
       terraform         ; infrastructure as code
       ;;tmux              ; an API for interacting with tmux
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if IS-MAC macos)  ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience

       :lang
       ;;agda                ; types of types of types of types...
       cc                  ; C/C++/Obj-C madness
       ;;clojure             ; java with a lisp
       ;;common-lisp         ; if you've seen one lisp, you've seen them all
       ;;coq                 ; proofs-as-programs
       ;;crystal             ; ruby at the speed of c
       ;;csharp              ; unity, .NET, and mono shenanigans
       data                ; config/data formats
       ;;(dart +flutter)     ; paint ui and not much else
       elixir              ; erlang done right
       ;;elm                 ; care for a cup of TEA?
       emacs-lisp          ; drown in parentheses
       (erlang +lsp)       ; an elegant language for a more civilized age
       ;;ess                 ; emacs speaks statistics
       ;;faust               ; dsp, but you get to keep your soul
       ;;fsharp              ; ML stands for Microsoft's Language
       ;;fstart              ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for
       (go +lsp)           ; the hipster dialect
       ;;(haskell +dante)    ; a language that's lazier than I am
       (haskell +lsp)      ; a language that's lazier than I am
       ;;hy                  ; readability of scheme w/ speed of python
       ;;idris               ; a language you can depend on
       json                ; At least it ain't XML
       (java +meghanada)   ; the poster child for carpal tunnel syndrome
       javascript          ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia               ; a better, faster MATLAB
       ;;kotlin              ; a better, slicker Java(Script)
       ;;latex               ; writing papers in Emacs has never been so fun
       ;;lean
       ;;factor
       ;;ledger              ; an accounting system in Emacs
       ;;lua                 ; one-based indices? one-based indices
       markdown            ; writing docs for people to ignore
       ;;nim                 ; python + lisp at the speed of c
       nix                 ; I hereby declare "nix geht mehr!"
       ;;ocaml               ; an objective camel
       (org                ; organize your plain life in plain text
        +dragndrop         ; drag & drop files/images into org buffers
        +hugo              ; use Emacs for hugo blogging
        +ipython           ; ipython/jupyter support for babel
        +pandoc            ; export-with-pandoc support
        +pomodoro          ; be fruitful with the tomato technique
        +present)          ; using org-mode for presentations
       php                 ; perl's insecure younger brother
       plantuml            ; diagrams for confusing people more
       ;;purescript          ; javascript, but functional
       python              ; beautiful is better than ugly
       ;;qt                  ; the 'cutest' gui framework ever
       ;;racket              ; a DSL for DSLs
       ;;raku              ; the artist formerly known as perl6
       ;;rest                ; Emacs as a REST client
       ;;rst                 ; ReST in peace
       ;;(ruby +rails)       ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       (rust +lsp)         ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;rust                ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scala               ; java, but good
       ;;scheme              ; a fully conniving family of lisps
       sh                  ; she sells {ba,z,fi}sh shells on the C xor
       ;;sml
       ;;solidity            ; do you need a blockchain? No.
       ;;swift               ; who asked for emoji variables?
       ;;terra               ; Earth and Moon in alignment for performance.
       web                 ; the tubes
       yaml                ; JSON, but readable

       :email
       ;;(mu4e +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       ;; Applications are complex and opinionated modules that transform Emacs
       ;; toward a specific purpose. They may have additional dependencies and
       ;; should be loaded late.
       :app
       ;;calendar
       ;;irc               ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an RSS reader
       ;;twitter           ; twitter client https://twitter.com/vnought

       :config
       ;;literate
       (default +bindings +smartparens))

; (custom-set-variables
;  ;; custom-set-variables was added by Custom.
;  ;; If you edit it by hand, you could mess it up, so be careful.
;  ;; Your init file should contain only one such instance.
;  ;; If there is more than one, they won't work right.
;  '(custom-safe-themes
;    (quote
;     ("ca0a98b766b64d98c24084e2fd2b74b795286a0ff322f53459fe60684c2fcffb" "d8e3a2b8c72c3cb52d070a5e1969849197488b92d7211cc86c97e033239fdde2" default)))
;  '(js-indent-level 2))
; (custom-set-faces
;  ;; custom-set-faces was added by Custom.
;  ;; If you edit it by hand, you could mess it up, so be careful.
;  ;; Your init file should contain only one such instance.
;  ;; If there is more than one, they won't work right.
;  )
