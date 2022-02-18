;;; config.el -*- lexical-binding: t; no-byte-compile: t; -*-

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

;; (setq doom-font (font-spec :family "Iosevka" :size 16)
;;       doom-big-font (font-spec :family "Iosevka" :size 30)
;;       doom-variable-pitch-font (font-spec :family "Noto Sans" :size 14))
;; <=> >> >>= >>> <<< <- -> ->> <-> &&
(setq doom-font (font-spec :family "Source Code Pro" :size 16)
      doom-big-font (font-spec :family "Source Code Pro" :size 30)
      doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 14))

;; Always softwrap
(global-visual-line-mode t)

;; Override line highlighting foreground
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (set-face-foreground 'highlight 'unspecified)))
(set-face-foreground 'highlight 'unspecified)

;; Disable clipboard manager hanging for a few seconds on Wayland
(setq x-select-enable-clipboard-manager nil)

;; Don't yank/etc. buffer to the x11-clipboard
(setq select-enable-clipboard nil)
(setq select-enable-primary nil)

;; Projectile default directory for my projects
(setq projectile-project-search-path '("~/dev/"))

;; Set notmuch backend to mbsync
; (setq +notmuch-sync-backend 'mbsync)

;; Make treemacs rename use a minibuffer
(setq treemacs-read-string-input 'from-minibuffer)

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
;; but disable trailing whitespace for the modes
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

;; Display a frame à la vscode at the top for M-x other things
(setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center))
      ivy-posframe-height-alist '((t . 10))
      ivy-posframe-parameters '((internal-border-width . 5)))
(setq ivy-posframe-border '((t (:background "#61BFFF"))))
;; (setq ivy-posframe-width (max 100 (- (frame-width) 10)))
(ivy-posframe-mode +1)

;; This is also called for ivy-posframe's size change ...
(add-to-list 'window-size-change-functions
             (lambda (frame)
               "Set ivy-posframe-width to a max width of 140 columns on frame resize."
               (let* ((ivy-frame (buffer-local-value 'posframe--frame (get-buffer ivy-posframe-buffer)))
                      (width (frame-width))
                      ;; Don't leave space on the sides when there is less than 70 columns
                      (min-width (max (min 70 width) (- width 10))))
                 (when (not (equal ivy-frame frame))
                   (setq ivy-posframe-width (min 140 min-width))))))

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
  :hook (vala-mode . (lambda () (lsp))))
