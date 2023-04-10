;;; config.el -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Code:
;; themes are THE MOST important setting
(require 'base16-theme)

;; Works for the server, but changes the theme for all frames...
;; (add-hook 'server-after-make-frame-hook
;;           (lambda ()
;;             (interactive)
;;             (if (display-graphic-p (selected-frame))
;;                 (setq doom-theme 'base16-tomorrow-night-eighties)
;;               (setq doom-theme 'wombat))
;;             (doom/reload-theme)))
(if (display-graphic-p (selected-frame))
    (setq doom-theme 'base16-tomorrow-night-eighties)
  (setq doom-theme 'wombat))


(setq display-line-numbers-type 'relative)

;; Display 5 lines below/above when scrolling
(setq scroll-margin 5)

;; <=> >> << >>= =<< >>> <<< -> <- ->> <<- <-> && ||
(setq doom-font (font-spec :family "Source Code Pro" :size 16)
      doom-big-font (font-spec :family "Source Code Pro" :size 30)
      doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 14))

;; Always softwrap
(global-visual-line-mode t)
(setq-default fill-column 80)
(global-display-fill-column-indicator-mode)

(defun disable-highlight-annoyances ()
    "Disables the annoying underline and foreground color change when a line is highlighted"
    (interactive)
    (set-face-attribute 'highlight nil :underline nil :foreground 'unspecified))
(add-hook 'server-after-make-frame-hook 'disable-highlight-annoyances)
(disable-highlight-annoyances)

;; Disable clipboard manager hanging for a few seconds on Wayland
(setq x-select-enable-clipboard-manager nil)
;; Don't yank/etc. buffer to the x11-clipboard
(setq select-enable-clipboard nil)
(setq select-enable-primary nil)

;; Projectile default directory for my projects
(setq projectile-project-search-path '("~/dev/"))

;; Set notmuch backend to mbsync
;; (setq +notmuch-sync-backend 'mbsync)

;; Make treemacs rename use a minibuffer
(setq treemacs-read-string-input 'from-minibuffer)

;; Set envrc global package through config variable
(setq envrc-direnv-executable "direnv")


;; Graciously donated by my friend: https://github.com/starcraft66/os-config/commit/9109152ea81c9398cc0a0d90a3728b44301ef56f
(after! exec-path-from-shell
  (when (memq window-system '(mac ns x))
    (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH"))
      (add-to-list 'exec-path-from-shell-variables var))
    (set exec-path-from-shell-arguments 'nil)
    (exec-path-from-sshell-initialize)))


(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--pch-storage=memory"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"
                                "--suggest-missing-includes"
                                ))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

;; Highlight trailing whitespacse by default
(setq-default show-trailing-whitespace 't)
(defun toggle-show-trailing-whitespace ()
  "Toggle `show-trailing-whitespace'"
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))
;; but disable trailing whitespace for these modes
(dolist (hook '(vterm-mode-hook
                term-mode-hook
                special-mode-hook
                comint-mode-hook
                compilation-mode-hook
                minibuffer-mode-hook))
  (add-hook hook (lambda ()
                   (set (make-local-variable 'show-trailing-whitespace) nil))))

;; Lets drag stuff aroung using hjkl
(map! :ne "C-S-k" #'drag-stuff-up)
(map! :ne "C-S-j" #'drag-stuff-down)
(map! :ne "C-S-l" #'drag-stuff-right)
(map! :ne "C-S-h" #'drag-stuff-left)

(map! :ne "SPC #" #'comment-or-uncomment-region)
(map! :ne "SPC =" #'indent-buffer)

(map! :ne "SPC j g" #'dumb-jump-go)
(map! :ne "SPC j b" #'dumb-jump-back)

;; Don't push a new buffer when navigating with RETURN in dired
;; Doesn't work
;; (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
;; (define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file "..")))

;; On vsplit using V, focus the new frame
(map! :ne "SPC w V" (lambda () (interactive)(evil-window-vsplit) (other-window 1)))

(add-hook 'yaml-mode-hook 'electric-indent-local-mode)

(setq frame-resize-pixelwise t)

(defun indent-buffer ()
  "Indent the whole buffer"
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))

(use-package! jsonnet-mode
  :defer t
  :mode "\\.jsonnet\\'"
  :config
  (set-electric! 'jsonnet-mode :chars '(?\n ?: ?{ ?})))

(use-package! vala-mode
  :defer t
  :mode "\\.vala\\'"
  :hook ((vala-mode . (lambda () (lsp)))
         (vala-mode . display-line-numbers-mode)))

;;; config.el ends here
