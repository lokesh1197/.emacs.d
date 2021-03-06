;; Required for functions that return functions ( used by custom function to filter tags in org-roam )
;; -*- lexical-binding: t; -*-

;; (setq debug-on-error t)
;; (setq debug-on-quit t)

;; (defconst emacs-start-time (current-time))

;; The default is 800 kilobytes.  Measured in bytes.
;; (setq gc-cons-threshold (* 50 1000 1000))
;; (setq gc-cons-threshold (* 100 1024 1024))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Using garbage magic hack.
;; (use-package gcmh
;;   :config
;;   (gcmh-mode 1))
;; ;; Setting garbage collection threshold
;; (setq gc-cons-threshold 402653184
;;       gc-cons-percentage 0.6)

;; ;; Profile emacs startup
;; (add-hook 'emacs-startup-hook
;;           (lambda ()
;;             (message "*** Emacs loaded in %s with %d garbage collections."
;;                      (format "%.2f seconds"
;;                              (float-time
;;                               (time-subtract after-init-time before-init-time)))
;;                      gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive (setq comp-async-report-warnings-errors nil)

;; Make gc pauses faster by decreasing the threshold.
;; (setq gc-cons-threshold (* 2 1000 1000))

;; Silence compiler warnings as they can be pretty disruptive
;; (setq native-comp-async-report-warnings-errors nil)

;; ;; Set the right directory to store the native comp cache
;; (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))

;; ;; Silence compiler warnings as they can be pretty disruptive
;; ;; (setq native-comp-deferred-compilation-deny-list nil)
;; (if (boundp 'comp-deferred-compilation)
;;     (setq comp-deferred-compilation nil)
;;   (setq native-comp-deferred-compilation nil))
;; ;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; ;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; ;; to skip the mtime checks on every *.elc file.
;; (setq load-prefer-newer noninteractive)

;; (setq package-enable-at-startup nil)

;; Bootstrap straight.el
(defvar bootstrap-version)
(setq straight-repository-branch "develop")
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Always use straight to install on systems other than Linux
(setq straight-use-package-by-default t)

;; Use straight.el for use-package expressions
(straight-use-package 'use-package)

;; call it early to prevent use of built-in org mode
(use-package org
  :straight org-contrib)

;; (org-babel-load-file
;;  (expand-file-name
;;   "config.org"
;;   user-emacs-directory))

;; Required if using package.el
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(let ((path (shell-command-to-string "source <(grep -v bind ~/.bashrc); echo -n $PATH")))
  (setenv "PATH" path)
  (setq exec-path
        (append
         (split-string-and-unquote path ":")
         exec-path)))

;; (menu-bar-mode -1)          ; Disable the menu bar
;; (scroll-bar-mode -1)        ; Disable visible scrollbar
;; (tool-bar-mode -1)          ; Disable the toolbar
;; (tooltip-mode -1)           ; Disable tooltips
;; (set-fringe-mode 10)        ; Give some breathing room

(column-number-mode)
(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

;; Disable line numbers for some modes
(dolist (mode '(vterm-mode-hook
                treemacs-mode-hook
                erc-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq scroll-conservatively 101) ;; value greater than 100 gets rid of half page jumping
(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; how many lines at a time
(setq mouse-wheel-progressive-speed t) ;; accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

;; (setq scroll-step 1)
;; (setq redisplay-dont-pause t)

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-gruvbox t)
  (doom-themes-org-config))

;; Fonts
;; condition-case is used to ignore error if font not found
(condition-case nil
  ;; (set-frame-font "Inconsolata 11" nil t) ;; Doesn't have italic font
  (set-frame-font "Source Code Pro 10" nil t)
  ;; (set-frame-font "Mononoki 12" nil t)
  ;; (set-frame-font "Fantasque Sans 12" nil t)
(error nil))

;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

;; Needed if using emacsclient. Otherwise, your fonts will be smaller than expected.
;;(add-to-list 'default-frame-alist '(font . "Inconsolata-11"))
;; changes certain keywords to symbols, such as lamda!
(setq global-prettify-symbols-mode t)

(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :config (unless (find-font (font-spec :name "all-the-icons"))
            (all-the-icons-install-fonts t)))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 25)) ;; lower height messes up the text vertical alignment
  )

;; Decrease modeline font height
(set-face-attribute 'mode-line nil :height 100)
(set-face-attribute 'mode-line-inactive nil :height 100)

(global-auto-revert-mode)

;; (general-define-key
;;   :states 'normal
;;   :mode evil-vimish-fold-mode
;;   "zF" 'vimish-fold-avy)

(use-package general
  :config
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer my/ctrl-c-keys
    :prefix "C-c")

  (general-evil-setup t)

  ;; general-simulate-key should not be quoted as it is supposed to be evaluated before assigning
  (my/leader-keys
    ;; "SPC" '(counsel-M-x :which-key "M-x")
    "."    '(find-file :which-key "find file")
    "SPC"  (general-simulate-key "M-x" :which-key "M-x") 
    "r"    (general-simulate-key "C-x r" :which-key "+register/bookmark") ;; run bookmark-save to save bookmarks to a file
    "t"    (general-simulate-key "C-x t" :which-key "+tab")
    "p"    (general-simulate-key "C-x p" :which-key "+project")
    "f"    (general-simulate-key "C-x 5" :which-key "+frame")
    "o"    '(:ignore t :which-key "open")
    "oa"   '(org-agenda :which-key "org-agenda")
    "oc"   '(org-capture :which-key "org-capture")
    "om"   '(mu4e :which-key "mu4e")
    "oe"   '(eshell :which-key "eshell")
    "op"   '(prodigy :which-key "prodigy")
    "ot"   '(vterm :which-key "vterm")
    "oy"   '(yas-insert-snippet :which-key "insert snippet")
    "hrr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :which-key "Reload emacs config")
    "hpc" '(lambda () (interactive) (find-file (expand-file-name "~/.config/emacs/config.org")) :which-key "Goto emacs config")

    "zt"    '(toggle-truncate-lines :whick-key "toggle truncate lines")
    )
  )

;; currently trying it instead of ibuffer
;; (use-package bufler
;;   ;; :disabled
;;   :after (evil evil-collection)
;;   :bind (("C-M-j" . bufler-switch-buffer)
;;         ("C-M-k" . bufler-workspace-frame-set))
;;  :config
;;  (evil-collection-define-key 'normal 'bufler-list-mode-map
;;    (kbd "RET")   'bufler-list-buffer-switch
;;    (kbd "M-RET") 'bufler-list-buffer-peek
;;    "D"           'bufler-list-buffer-kill)
;;   )

(use-package ibuffer
  :straight (:type built-in)
  :config
  ;; (setq ibuffer-saved-filter-groups
  ;;       '(("home"
  ;;   ("emacs-config" (or (filename . ".config/emacs")
  ;;           (filename . "emacs-config")))
  ;;         ("martinowen.net" (filename . "martinowen.net"))
  ;;   ("Org" (or (mode . org-mode)
  ;;         (filename . "OrgMode")))
  ;;         ("code" (filename . "code"))
  ;;   ("Web Dev" (or (mode . html-mode)
  ;;       (mode . css-mode)))
  ;;   ("Subversion" (name . "\*svn"))
  ;;   ("Magit" (name . "\*magit"))
  ;;   ("ERC" (mode . erc-mode))
  ;;   ("Help" (or (name . "\*Help\*")
  ;;         (name . "\*Apropos\*")
  ;;         (name . "\*info\*"))))))
  (setq ibuffer-expert t)
  (setq ibuffer-show-empty-filter-groups nil))

  (my/leader-keys
    "b"     '(:ignore t :which-key "buffer")
    "b b"   '(ibuffer :which-key "ibuffer")
    "b o"   '(ibuffer-other-window :which-key "ibuffer in other window")
    ;; "b b"   '(bufler :which-key "buffer list")
    ;; "b s"   '(switch-to-buffer :which-key "switch buffer")
    "b s"   '(consult-buffer :which-key "switch buffer")
    "b f"   '(consult-buffer-other-frame :which-key "open buffer in other frame")
    "b w"   '(consult-buffer-other-window :which-key "open buffer in other window")
    "b c"   '(clone-indirect-buffer-other-window :which-key "Clone buffer in other window")
    "b k"   '(kill-current-buffer :which-key "Kill current buffer")
    "b n"   '(next-buffer :which-key "Next buffer")
    "b p"   '(previous-buffer :which-key "Previous buffer")
    "b B"   '(ibuffer-list-buffers :which-key "Ibuffer list buffers")
    "b K"   '(kill-buffer :which-key "Kill buffer"))

;; (my/leader-keys
;;   "."     '(find-file :which-key "Find file")
;;   "f"     '(:ignore t :which-key "file")
;;   "f f"   '(find-file :which-key "Find file")
;;   "f r"   '(counsel-recentf :which-key "Recent files")
;;   "f s"   '(save-buffer :which-key "Save file")
;;   "f u"   '(sudo-edit-find-file :which-key "Sudo find file")
;;   "f C"   '(copy-file :which-key "Copy file")
;;   "f D"   '(delete-file :which-key "Delete file")
;;   "f R"   '(rename-file :which-key "Rename file")
;;   "f S"   '(write-file :which-key "Save file as...")
;;   "f U"   '(sudo-edit :which-key "Sudo edit file"))

(use-package ace-window
  :config
  (global-set-key (kbd "M-o") 'ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-scope 'frame)
  (aw-dispatch-always t))

(use-package winner-mode
  :straight (:type built-in)
  :bind (:map evil-window-map
              ("u" . winner-undo)
              ("C-u" . winner-redo))
  :config
  (winner-mode))

(my/leader-keys
  "w"     '(:ignore t :which-key "window")
  "w c"   '(evil-window-delete :which-key "Close window")
  "w n"   '(evil-window-new :which-key "New window")
  "w s"   '(evil-window-split :which-key "Horizontal split window")
  "w v"   '(evil-window-vsplit :which-key "Vertical split window")
  ;; Window motions
  "w h"   '(evil-window-left :which-key "Window left")
  "w j"   '(evil-window-down :which-key "Window down")
  "w k"   '(evil-window-up :which-key "Window up")
  "w l"   '(evil-window-right :which-key "Window right")
  "w w"   '(evil-window-next :which-key "Goto next window")
  )

;; If a popup does happen, don't resize windows to be equal-sized
(setq even-window-sizes nil)

;; Returns the parent directory containing a .project file, if any,
;; to override the standard project detection logic when needed.
(defun my-project-override (dir)
  (let ((override (locate-dominating-file dir ".project")))
    (if override
        (cons 'vc override)
      nil)))

(use-package project
  ;; Cannot use :hook because 'project-find-functions does not end in -hook
  :config
  (add-hook 'project-find-functions #'my-project-override))

(use-package popper
  :straight (popper :host github
                    :repo "karthink/popper"
                    :build (:not autoloads))
  ;; :commands popper-mode
  :bind (("M-'" . popper-toggle-latest)
         ("C-'" . popper-cycle)
         ("C-M-'" . popper-toggle-type))
  :config
  (setq popper-mode-line nil)      

  :custom
  (popper-window-height 15)
  (popper-group-function #'popper-group-by-project)
  (popper-reference-buffers
   '("\\*Async Shell Command\\*"
     ;; +occur-grep-modes-list
     ;; +man-modes-list
     ;; messages-buffer-mode
     ;; "^\\*Warnings\\*$"
     ;; "^\\*Compile-Log\\*$"
     ;; "^\\*Matlab Help\\*"
     ;; "^\\*Messages\\*$"
     ;; "^\\*Backtrace\\*"
     ;; "^\\*evil-registers\\*"
     ;; "^\\*Apropos"
     ;; "^Calc:"
     ;; "^\\*TeX errors\\*"
     ;; "^\\*ielm\\*"
     ;; "^\\*TeX Help\\*"
     ;; "\\*Shell Command Output\\*"
     ;; "\\*Completions\\*"
     ;; "\\*scratch\\*"
     ;; "[Oo]utput\\*"
     ;; special-mode
     vterm-mode
     shell-mode
     esh-mode
     eshell-mode
     apropos-mode
     help-mode
     helpful-mode
     compilation-mode))
  :init
  ;; Needed because I disabled autoloads
  (require 'popper)
  (popper-mode 1))

;; (setq tab-bar-new-tab-choice "*scratch*")

;; (setq tab-bar-close-button-show nil
;;       tab-bar-new-button-show nil 
;;       ;; tab-bar-separator " | "
;;       ;; tab-bar-button-relief 10
;;       ;; tab-bar-button-margin 10
;;       )

;; Don't turn on tab-bar-mode when tabs are created
;; (setq tab-bar-show nil)

;; ;; Get the current tab name for use in some other display
;; (defun efs/current-tab-name ()
;;   (alist-get 'name (tab-bar--current-tab)))

;; (nvmap :prefix "SPC"
;;   "r c"   '(copy-to-register :which-key "Copy to register")
;;   "r f"   '(frameset-to-register :which-key "Frameset to register")
;;   "r i"   '(insert-register :which-key "Insert register")
;;   "r j"   '(jump-to-register :which-key "Jump to register")
;;   "r l"   '(list-registers :which-key "List registers")
;;   "r n"   '(number-to-register :which-key "Number to register")
;;   "r r"   '(counsel-register :which-key "Choose a register")
;;   "r v"   '(view-register :which-key "View a register")
;;   "r w"   '(window-configuration-to-register :which-key "Window configuration to register")
;;   "r +"   '(increment-register :which-key "Increment register")
;;   "r SPC" '(point-to-register :which-key "Point to register"))

;; (global-set-key (kbd "C-=") 'text-scale-increase)
;; (global-set-key (kbd "C--") 'text-scale-decrease)
;; (global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
;; (global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package evil
  :after general
  :init      ;; config before the package loads
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  ;; (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode)
  (bind-keys* ("M-f" . evil-normal-state))
  (general-define-key
    :states '(insert visual normal)
    "M-f" 'evil-normal-state)

  ;; Use visual line motions even outside of visual-line-mode buffers(replacement for gj, gk)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; ;; Make sure some modes start in Emacs state
  ;; (dolist (mode '(custom-mode
  ;;                 eshell-mode
  ;;                 term-mode))
  ;;   (add-to-list 'evil-emacs-state-modes mode))

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'erc-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; (with-eval-after-load 'org
;;   (define-key org-mode-map (kbd "M-f") 'evil-normal-state))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :config
  (evil-commentary-mode))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package helpful
  :commands (helpful-at-point
            helpful-callable
            helpful-command
            helpful-function
            helpful-key
            helpful-macro
            helpful-variable)
  :bind
  ([remap display-local-help] . helpful-at-point)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command))

(use-package which-key
  :defer 0.2
  :delight
  ;; :diminish
  :custom (which-key-idle-delay 0.5)
  :config (which-key-mode))

(use-package hydra
  :bind (("C-c I" . hydra-image/body)
         ("C-c L" . hydra-ledger/body)
         ("C-c M" . hydra-merge/body)
         ("C-c T" . hydra-tool/body)
         ("C-c b" . hydra-btoggle/body)
         ("C-c c" . hydra-clock/body)
         ("C-c e" . hydra-erc/body)
         ("C-c f" . hydra-flycheck/body)
         ("C-c g" . hydra-go-to-file/body)
         ("C-c m" . hydra-magit/body)
         ;; ("C-c o" . hydra-org/body)
         ("C-c o" . hydra-org-download/body)
         ("C-c s" . hydra-spelling/body)
         ("C-c t" . hydra-tex/body)
         ("C-c u" . hydra-upload/body)
         ("C-c N" . hydra-notes/body)
         ("C-c w" . hydra-windows/body)))

(use-package major-mode-hydra
  :after hydra
  :preface
  (defun with-alltheicon (icon str &optional height v-adjust face)
    "Display an icon from all-the-icon."
    (s-concat (all-the-icons-alltheicon icon :v-adjust (or v-adjust 0) :height (or height 1) :face face) " " str))

  (defun with-faicon (icon str &optional height v-adjust face)
    "Display an icon from Font Awesome icon."
    (s-concat (all-the-icons-faicon icon ':v-adjust (or v-adjust 0) :height (or height 1) :face face) " " str))

  (defun with-fileicon (icon str &optional height v-adjust face)
    "Display an icon from the Atom File Icons package."
    (s-concat (all-the-icons-fileicon icon :v-adjust (or v-adjust 0) :height (or height 1) :face face) " " str))

  (defun with-octicon (icon str &optional height v-adjust face)
    "Display an icon from the GitHub Octicons."
    (s-concat (all-the-icons-octicon icon :v-adjust (or v-adjust 0) :height (or height 1) :face face) " " str)))

(pretty-hydra-define hydra-org-download
  (:hint nil :color teal :quit-key "q" :title (with-fileicon "org" "Org Download" 1 -0.05))
  ("Action"
   (("c" org-download-clipboard "Capture the image from the clipboard and insert the resulting file")
    ("d" org-download-delete "Delete inline image link on current line, and the file that it points to")
    ("d" org-download-edit "Open the image at point for editing.")
    ("i" org-download-image "Save image at address LINK to ???org-download--dir???.")
    ("p" org-download-rename-at-point "Rename image at point.")
    ("f" org-download-rename-last-file "Rename the last downloaded file saved in your computer.")
    ("s" org-download-screenshot "Capture screenshot and insert the resulting file.")
    ("y" org-download-yank "Call ???org-download-image??? with current kill."))))

(pretty-hydra-define hydra-btoggle
  (:hint nil :color amaranth :quit-key "q" :title (with-faicon "toggle-on" "Toggle" 1 -0.05))
  ("Basic"
   (("a" abbrev-mode "abbrev" :toggle t)
    ("h" global-hungry-delete-mode "hungry delete" :toggle t))
   "Coding"
   (("e" electric-operator-mode "electric operator" :toggle t)
    ("F" flyspell-mode "flyspell" :toggle t)
    ("f" flycheck-mode "flycheck" :toggle t)
    ("l" lsp-mode "lsp" :toggle t)
    ("s" smartparens-mode "smartparens" :toggle t))
   "UI"
   (("i" ivy-rich-mode "ivy-rich" :toggle t))))

(pretty-hydra-define hydra-erc
  (:hint nil :color teal :quit-key "q" :title (with-faicon "comments-o" "ERC" 1 -0.05))
  ("Action"
   (("c" erc "connect")
    ("d" erc-quit-server "disconnect")
    ("j" erc-join-channel "join")
    ("n" erc-channel-names "names")
    ("t" erc-tls "connect with tls/ssl")
    ("r" my/connect-irc "connect me"))))

(pretty-hydra-define hydra-clock
  (:hint nil :color teal :quit-key "q" :title (with-faicon "clock-o" "Clock" 1 -0.05))
  ("Action"
   (("c" org-clock-cancel "cancel")
    ("d" org-clock-display "display")
    ("e" org-clock-modify-effort-estimate "effort")
    ("i" org-clock-in "in")
    ("j" org-clock-goto "jump")
    ("o" org-clock-out "out")
    ("p" org-pomodoro "pomodoro")
    ("r" org-clock-report "report"))))

(pretty-hydra-define hydra-flycheck
  (:hint nil :color teal :quit-key "q" :title (with-faicon "plane" "Flycheck" 1 -0.05))
  ("Checker"
   (("?" flycheck-describe-checker "describe")
    ("d" flycheck-disable-checker "disable")
    ("m" flycheck-mode "mode")
    ("s" flycheck-select-checker "select"))
   "Errors"
   (("<" flycheck-previous-error "previous" :color pink)
    (">" flycheck-next-error "next" :color pink)
    ("f" flycheck-buffer "check")
    ("l" flycheck-list-errors "list"))
   "Other"
   (("M" flycheck-manual "manual")
    ("v" flycheck-verify-setup "verify setup"))))

(pretty-hydra-define hydra-go-to-file
  (:hint nil :color teal :quit-key "q" :title (with-octicon "file-symlink-file" "Go To" 1 -0.05))
  ("Agenda"
   (("ac" (find-file "~/.personal/agenda/contacts.org") "contacts")
    ("ah" (find-file "~/.personal/agenda/home.org") "home")
    ("ai" (find-file "~/.personal/agenda/inbox.org") "inbox")
    ("ap" (find-file "~/.personal/agenda/people.org") "people")
    ("ar" (find-file "~/.personal/agenda/routine.org") "routine")
    ("aw" (find-file "~/.personal/agenda/work.org") "work"))
   "Config"
   (("ca" (find-file (format "%s/alacritty/alacritty.yml" xdg-config)) "alacritty")
    ("cA" (find-file (format "%s/sh/aliases" xdg-config)) "aliases")
    ("ce" (find-file "~/.config/emacs/config.org") "emacs")
    ("cE" (find-file (format "%s/sh/environ" xdg-config)) "environ")
    ("cn" (find-file (format "%s/neofetch/config.conf" xdg-config)) "neofetch")
    ("cq" (find-file (format "%s/qutebrowser/config.py" xdg-config)) "qutebrowser")
    ("cr" (find-file (format "%s/ranger/rc.conf" xdg-config)) "ranger")
    ("cs" (find-file (format "%s/sway/config" xdg-config)) "sway")
    ("ct" (find-file (format "%s/tmux/tmux.conf" xdg-config)) "tmux")
    ("cw" (find-file (format "%s/waybar/config" xdg-config)) "waybar")
    ("cW" (find-file (format "%s/wofi/config" xdg-config)) "wofi")
    ("cx" (find-file (format "%s/sh/xdg" xdg-config)) "xdg"))
   "Notes"
   (("na" (find-file (format "~/.personal/notes/affirmations.pdf" xdg-config)) "Affirmations"))
   "Other"
   (("ob" (find-file "~/.personal/other/books.org") "book")
    ("ol" (find-file "~/.personal/other/long-goals.org") "long-terms goals")
    ("om" (find-file "~/.personal/other/movies.org"))
    ("op" (find-file "~/.personal/other/purchases.org") "purchase")
    ("os" (find-file "~/.personal/other/short-goals.org") "short-terms goals")
    ("ou" (find-file "~/.personal/other/usb.org") "usb")
    ("oL" (find-file "~/.personal/other/learning.org") "learning"))))

(pretty-hydra-define hydra-image
  (:hint nil :color pink :quit-key "q" :title (with-faicon "file-image-o" "Images" 1 -0.05))
  ("Action"
   (("r" image-rotate "rotate")
    ("s" image-save "save" :color teal))
    "Zoom"
    (("-" image-decrease-size "out")
     ("+" image-increase-size "in")
     ("=" image-transform-reset "reset"))))

(pretty-hydra-define hydra-ledger
  (:hint nil :color teal :quit-key "q" :title (with-faicon "usd" "Ledger" 1 -0.05))
  ("Action"
   (("b" ledger-add-transaction "add")
    ("c" ledger-mode-clean-buffer "clear")
    ("i" ledger-copy-transaction-at-point "copy")
    ("s" ledger-delete-current-transaction "delete")
    ("r" ledger-report "report"))))

(pretty-hydra-define hydra-magit
  (:hint nil :color teal :quit-key "q" :title (with-octicon "mark-github" "Magit" 1 -0.05))
  ("Action"
   (("b" magit-blame "blame")
    ("c" magit-clone "clone")
    ("i" magit-init "init")
    ("l" magit-log-buffer-file "commit log (current file)")
    ("L" magit-log-current "commit log (project)")
    ("s" magit-status "status"))))

(pretty-hydra-define hydra-merge
  (:hint nil :color pink :quit-key "q" :title (with-octicon "mark-github" "Magit" 1 -0.05))
  ("Move"
   (("n" smerge-next "next")
    ("p" smerge-prev "previous"))
   "Keep"
   (("RET" smerge-keep-current "current")
    ("a" smerge-keep-all "all")
    ("b" smerge-keep-base "base")
    ("l" smerge-keep-lower "lower")
    ("u" smerge-keep-upper "upper"))
   "Diff"
   (("<" smerge-diff-base-upper "upper/base")
    ("=" smerge-diff-upper-lower "upper/lower")
    (">" smerge-diff-base-lower "base/lower")
    ("R" smerge-refine "redefine")
    ("E" smerge-ediff "ediff"))
   "Other"
   (("C" smerge-combine-with-next "combine")
    ("r" smerge-resolve "resolve")
    ("k" smerge-kill-current "kill current"))))

;; ;; Configure leader key
;; (evil-leader/set-key-for-mode 'org-mode
;;   "." 'hydra-org-state/body
;;   "t" 'org-todo
;;   "T" 'org-show-todo-tree
;;   "v" 'org-mark-element
;;   "a" 'org-agenda
;;   "c" 'org-archive-subtree
;;   "l" 'evil-org-open-links
;;   "C" 'org-resolve-clocks)

(pretty-hydra-define hydra-org
  (:hint nil :color teal :quit-key "q" :title (with-fileicon "org" "Org" 1 -0.05))
  ("Action"
   (("A" my/org-archive-done-tasks "archive")
    ("a" org-agenda "agenda")
    ("c" org-capture "capture")
    ("d" org-decrypt-entry "decrypt")
    ("i" org-insert-link-global "insert-link")
    ("j" my/org-jump "jump-task")
    ("k" org-cut-subtree "cut-subtree")
    ("o" org-open-at-point-global "open-link")
    ("r" org-refile "refile")
    ("s" org-store-link "store-link")
    ("t" org-show-todo-tree "todo-tree"))))

(defhydra hydra-org-state ()
  ;; basic navigation
  ("i" org-cycle)
  ("I" org-shifttab)
  ;; ("h" org-up-element)
  ;; ("l" org-down-element)
  ;; ("j" org-forward-element)
  ;; ("k" org-backward-element)
  ;; navigating links
  ("n" org-next-link)
  ("p" org-previous-link)
  ("o" org-open-at-point)
  ;; navigation blocks
  ("N" org-next-block)
  ("P" org-previous-block)
  ;; updates
  ("." org-ctrl-c-ctrl-c)
  ("*" org-ctrl-c-star)
  ("-" org-ctrl-c-minus)
  ;; change todo state
  ("H" org-shiftleft)
  ("L" org-shiftright)
  ("J" org-shiftdown)
  ("K" org-shiftup)
  ("t" org-todo))

(pretty-hydra-define hydra-notes
  (:hint nil :color teal :quit-key "q" :title (with-octicon "pencil" "Notes" 1 -0.05))
  ("Notes"
   (("c" org-roam-dailies-capture-today "capture")
    ("C" org-roam-dailies-capture-tomorrow "capture tomorrow")
    ("g" org-roam-graph "graph")
    ("f" org-roam-node-find "find")
    ("i" org-roam-node-insert "insert"))
   "Go To"
   ((">" org-roam-dailies-goto-next-note "next note")
    ("<" org-roam-dailies-goto-previous-note "previous note")
    ("d" org-roam-dailies-goto-date "date")
    ("t" org-roam-dailies-goto-today "today")
    ("T" org-roam-dailies-goto-tomorrow "tomorrow")
    ("y" org-roam-dailies-goto-yesterday "yesterday"))))

(pretty-hydra-define hydra-spelling
  (:hint nil :color teal :quit-key "q" :title (with-faicon "magic" "Spelling" 1 -0.05))
  ("Checker"
   (("c" langtool-correct-buffer "correction")
    ("C" langtool-check-done "clear")
    ("d" ispell-change-dictionary "dictionary")
    ("l" (message "Current language: %s (%s)" langtool-default-language ispell-current-dictionary) "language")
    ("s" my/switch-language "switch")
    ("w" wiki-summary "wiki"))
   "Errors"
   (("<" flyspell-correct-previous "previous" :color pink)
    (">" flyspell-correct-next "next" :color pink)
    ("f" langtool-check "find"))))

(pretty-hydra-define hydra-tex
  (:hint nil :color teal :quit-key "q" :title (with-fileicon "tex" "LaTeX" 1 -0.05))
  ("Action"
   (("g" reftex-goto-label "goto")
    ("r" reftex-query-replace-document "replace")
    ("s" counsel-rg "search")
    ("t" reftex-toc "table of content"))))

(pretty-hydra-define hydra-tool
  (:hint nil :color teal :quit-key "q" :title (with-faicon "briefcase" "Tool" 1 -0.05))
  ("Network"
   (("c" ipcalc "subnet calculator")
    ("i" ipinfo "ip info"))))

(defhydra hydra-typescript (:color blue)
  "
  ^
  ^TypeScript^          ^Do^
  ^??????????????????????????????^??????????????????????????????^??????^?????????????????????????????????
  _q_ quit             _b_ back
  ^^                   _e_ errors
  ^^                   _j_ jump
  ^^                   _r_ references
  ^^                   _R_ restart
  ^^                   ^^
  "
  ("q" nil)
  ("b" tide-jump-back)
  ("e" tide-project-errors)
  ("j" tide-jump-to-definition)
  ("r" tide-references)
  ("R" tide-restart-server))

(pretty-hydra-define hydra-upload
  (:hint nil :color teal :quit-key "q" :title (with-faicon "cloud-upload" "Upload" 1 -0.05))
  ("Action"
   (("b" webpaste-paste-buffer "buffer")
    ("i" imgbb-upload "image")
    ("r" webpaste-paste-region "region"))))

(pretty-hydra-define hydra-windows
  (:hint nil :forein-keys warn :quit-key "q" :title (with-faicon "windows" "Windows" 1 -0.05))
  ("Window"
   (("b" balance-windows "balance")
    ("i" enlarge-window "heighten")
    ("j" shrink-window-horizontally "narrow")
    ("k" shrink-window "lower")
    ("u" winner-undo "undo")
    ("r" winner-redo "redo")
    ("l" enlarge-window-horizontally "widen")
    ("s" switch-window-then-swap-buffer "swap" :color teal))
   "Zoom"
   (("-" text-scale-decrease "out")
    ("+" text-scale-increase "in")
    ("=" (text-scale-increase 0) "reset"))))

;; (use-package writeroom-mode)

(use-package yasnippet
  :config
  ;; (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  (yas-global-mode 1)   ;; enables yasnippet globally
  )

;; collection of common snippets
(use-package yasnippet-snippets)

(use-package faces
  :straight (:type built-in)
  :custom (show-paren-delay 0)
  :config
  (set-face-background 'show-paren-match "#161719")
  (set-face-bold 'show-paren-match t)
  (set-face-foreground 'show-paren-match "#ffffff"))

;; Turn on matching parenthesis highlighting
;; Commented as it doesn't work properly. A fix is required
;; (show-paren-mode 1)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Enable electric-pair-mode globally
(electric-pair-mode 1)

(my/leader-keys
  "d d" '(dired :which-key "Open dired")
  "d j" '(dired-jump :which-key "Dired jump to current")
  )

(use-package dired
  :straight (:type built-in)
  :commands (dired dired-jump)
  :hook
  (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map
  ("C-c h" . hydra-dired/body)
  ("C-c o" . dired-open-file))
  :general
  (:states 'normal
     :keymaps 'dired-mode-map
     "l" 'dired-find-file
     "h" 'dired-up-directory)
  :delight "Dired"
  :config
  (setq delete-by-moving-to-trash t)
  ;; (dired-async-mode 1)
  :custom
  (dired-auto-revert-buffer t)
  (dired-dwim-target t)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-omit-files "^\\.[^.].*")
  (dired-omit-verbose nil)
  (dired-listing-switches "-Alh1vD --group-directories-first")
  (dired-ls-F-marks-symlinks nil)
  (dired-recursive-copies 'always)
  )

(pretty-hydra-define hydra-dired
  (:hint nil :color teal :quit-key "q" :title (with-fileicon "org" "Dired" 1 -0.05))
  ("Action"
   (("o" dired-omit-mode "toggle visibility of ommited files")
    ("c" dired-collapse-mode "toggle dired collapse")
    ("b" dired-ranger-bookmark "bookmark current dired buffer")
    ("v" dired-ranger-bookmark-visit "visit dired bookmark")
    ("c" dired-ranger-copy "copy like ranger")
    ("r" dired-ranger-copy-ring "view copy ring")
    ("m" dired-ranger-move "move like ranger")
    ("p" dired-ranger-paste "paste like ranger"))))

;; (add-hook 'dired-mode-hook
;;           (lambda ()
;;             (interactive)
;;             (dired-omit-mode 1)
;;             (dired-hide-details-mode 1)
;;             (hl-line-mode 1)))

(use-package dired-single
  :after dired
  :bind (:map dired-mode-map
              ([remap dired-find-file] . dired-single-buffer)
              ([remap dired-up-directory] . dired-single-up-directory)
              ("M-DEL" . dired-prev-subdir)))

(use-package dired-open
  :after (dired dired-jump)
  :custom (dired-open-extensions '(("mp4" . "mpv"))))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  ;; :hook (dired-mode . dired-hide-dotfiles-mode)
  :general
  (:states 'normal
     :keymaps 'dired-mode-map
     ")" 'dired-hide-dotfiles-mode))

(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)))

(use-package dired-narrow
  ;; :straight (:type built-in)
  :bind (("C-c C-n" . dired-narrow)
         ("C-c C-f" . dired-narrow-fuzzy)))

;; (use-package diredfl
;;   ;; :hook (dired-mode . diredfl-mode)
;;   :config
;;   (diredfl-global-mode))

;; (use-package dired-rainbow
;;   :config
;;   (progn
;;     (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
;;     (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
;;     (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
;;     (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
;;     (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
;;     (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
;;     (dired-rainbow-define media "#de751f" ("mp3" "mp4" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
;;     (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
;;     (dired-rainbow-define log "#c17d11" ("log"))
;;     (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
;;     (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
;;     (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
;;     (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
;;     (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
;;     (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
;;     (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
;;     (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
;;     (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
;;     (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
;;     (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*")
;;     ))

(use-package dired-ranger
  :defer t)

(use-package dired-collapse
  :defer t)

(use-package dashboard
  :init
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.config/emacs/emacs-dash.png")  ;; use custom image as banner
  (setq dashboard-center-content nil)

  :config
  (dashboard-setup-startup-hook)
)

(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

;; (condition-case nil
;; (add-to-list 'load-path "/home/lokesh/.config/emacs/straight/repos/emacs-libvterm")
;;   (require 'vterm)
;;  (error nil))

(use-package vterm
  ;; :straight nil
  :custom
  (vterm-shell "fish"))

;; (use-package vterm
;;   :after evil-collection
;;   :commands vterm
;;   :config
;;   (setq vterm-max-scrollback 10000)
;;   (advice-add 'evil-collection-vterm-insert :before #'vterm-reset-cursor-point))

(use-package vertico
  :straight (:files (:defaults "extensions/*"))
  :init (vertico-mode)
  :bind (:map vertico-map
                ("C-j" . vertico-next)
                ("C-k" . vertico-previous)
                ("DEL" . vertico-directory-delete-char)
                ("M-DEL" . vertico-directory-delete-word)
                ("C-<backspace>" . vertico-directory-up)
                ("C-f" . vertico-quick-insert))
  :custom (vertico-cycle t)
  )

(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style. See
;; `+orderless-dispatch' in the Consult wiki for an advanced Orderless style
;; dispatcher. Additionally enable `partial-completion' for file path
;; expansion. `partial-completion' is important for wildcard support.
;; Multiple files can be opened at once with `find-file' if you enter a
;; wildcard. You may also give the `initials' completion style a try.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch))
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :after vertico
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  ;; :bind (("M-A" . marginalia-cycle)
  ;;        :map minibuffer-local-map
  ;;        ("M-A" . marginalia-cycle))

  ;; :custom
  ;; (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup))

(use-package consult
  :demand t
  :bind (("C-s" . consult-line)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  ;; :custom
  ;; (consult-project-root-function #'my/get-project-root)
  ;; (completion-in-region-function #'consult-completion-in-region)
  )

(my/leader-keys
  "s"     '(:ignore t :which-key "search")
  "s s"   '(consult-line :which-key "search in current file")
  "s g"   '(consult-ripgrep :which-key "grep in current directory")
  ;; "s h"   '(consult-imenu :which-key "search headings in current file")
  "s h"   '(consult-outline :which-key "search headings in current file")
  "s o"   '(consult-org-heading :which-key "search org heading in current file")
  "s m"   '(consult-man :which-key "search man with regexp")
  )

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  ;; :map minibuffer-local-map
  ;; ("C-d" . embark-act))

  :init
  ;; Required as C-. is binded in evil
  (general-define-key
   :states '(normal visual)
   "C-." 'embark-act)

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Show Embark actions via which-key
  ;; (setq embark-action-indicator
  ;;       (lambda (map)
  ;;         (which-key--show-keymap "Embark" map nil nil 'no-paging)
  ;;         #'which-key--hide-popup-ignore-command)
  ;;       embark-become-indicator embark-action-indicator)

  ;; Hide the mode line of the Embark live/completions buffers
  ;; (add-to-list 'display-buffer-alist
  ;;              '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
  ;;                nil
  ;;                (window-parameters (mode-line-format . none))))
  )

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  ;; :demand t ; only necessary if you have the hook below
  ;; ;; if you want to have consult previews as you move around an
  ;; ;; auto-updating embark collect buffer
  ;; :hook
  ;; (embark-collect-mode . consult-preview-at-point-mode)
  )

(use-package corfu
  :straight '(corfu :host github
                    :repo "minad/corfu")
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-commit-predicate nil)   ;; Do not commit selected candidates on next input
  ;; (corfu-quit-at-boundary t)     ;; Automatically quit at word boundary
  ;; (corfu-quit-no-match t)        ;; Automatically quit if there is no match
  ;; (corfu-echo-documentation nil) ;; Do not show documentation in the echo area

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("C-j" . corfu-next)
              ("C-k" . corfu-previous))

  ;; You may want to enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since dabbrev can be used globally (M-/).
  :init
  (global-corfu-mode))

;; Emacs tries to complete the word by searching all open buffers
;; Dabbrev is in-built into emacs. It works with Corfu
(use-package dabbrev
  :straight (:type built-in)
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config 
  ;; make dabbrev case sensitive
  (setq dabbrev-case-fold-search nil))

;; A few more useful configurations...
(use-package emacs
  :straight (:type built-in)
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

(use-package consult-dir
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file))
  :custom
 (consult-dir-project-list-function nil)
 )

;; ;; Thanks Karthik!
;; (with-eval-after-load 'eshell-mode
;;   (defun eshell/z (&optional regexp)
;;     "Navigate to a previously visited directory in eshell."
;;     (let ((eshell-dirs (delete-dups (mapcar 'abbreviate-file-name
;;                                             (ring-elements eshell-last-dir-ring)))))
;;       (cond
;;        ((and (not regexp) (featurep 'consult-dir))
;;         (let* ((consult-dir--source-eshell `(:name "Eshell"
;;                                                    :narrow ?e
;;                                                    :category file
;;                                                    :face consult-file
;;                                                    :items ,eshell-dirs))
;;                (consult-dir-sources (cons consult-dir--source-eshell consult-dir-sources)))
;;           (eshell/cd (substring-no-properties (consult-dir--pick "Switch directory: ")))))
;;        (t (eshell/cd (if regexp (eshell-find-previous-directory regexp)
;;                        (completing-read "cd: " eshell-dirs))))))))

;; ;; A few more useful configurations...
;; (use-package emacs
;;   :init
;;   ;; Add prompt indicator to `completing-read-multiple'.
;;   ;; Alternatively try `consult-completing-read-multiple'.
;;   (defun crm-indicator (args)
;;     (cons (concat "[CRM] " (car args)) (cdr args)))
;;   (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

;;   ;; Do not allow the cursor in the minibuffer prompt
;;   (setq minibuffer-prompt-properties
;;         '(read-only t cursor-intangible t face minibuffer-prompt))
;;   (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

;;   ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
;;   ;; Vertico commands are hidden in normal buffers.
;;   ;; (setq read-extended-command-predicate
;;   ;;       #'command-completion-default-include-p)

;;   ;; Enable recursive minibuffers
;;   (setq enable-recursive-minibuffers t))

(use-package avy
  :commands (avy-goto-char avy-goto-word-0 avy-goto-word-1 avy-goto-line)
  :init
  (general-define-key
   :states '(normal visual)
   "F" 'avy-goto-char-timer)
  )

(use-package evil-snipe
  ;; :init
  ;; (general-define-key
  ;;  :states '(normal visual)
  ;;  "f" 'evil-snipe-f
  ;;  ;; "F" 'evil-snipe-F
  ;;  "t" 'evil-snipe-t
  ;;  "T" 'evil-snipe-T)
  :custom
  (evil-snipe-scope 'whole-visible)
  (evil-snipe-auto-scroll t)
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode 1)
  (push 'prodigy-mode evil-snipe-disabled-modes)
  )

(use-package evil-easymotion
  :config
  (evilem-default-keybindings "H"))

(my/leader-keys
  "j"   '(:ignore t :which-key "jump")
  "jj"  '(avy-goto-char :which-key "jump to char")
  ;; "jw"  '(avy-goto-word-0 :which-key "jump to word")
  "jL"  '(avy-goto-end-of-line :which-key "Avy goto line")
  "jw"  '(avy-goto-word-1 :which-key "jump to word starting with")
  "jl"  '(avy-goto-line :which-key "jump to line")
  "jm"  '(avy-move-line :which-key "Avy move line")
  "jM"  '(avy-move-region :which-key "Avy move region")
  "jc"  '(avy-copy-line :which-key "Avy copy line above")
  "jC"  '(avy-copy-region :which-key "Avy copy region above")
  "jk"  '(avy-kill-whole-line :which-key "Avy copy line as kill")
  "jK"  '(avy-kill-region :which-key "Avy kill region")
  "jp"  '(avy-kill-ring-save-region :which-key "Avy copy as kill")
  )

(use-package prodigy
  :init
  (prodigy-define-tag
    :name 'email
    :ready-message "Checking Email using IMAP IDLE. Ctrl-C to shutdown.")
  (prodigy-define-tag
    :name 'desktop
    :ready-message "Desktop services. Ctrl-C to shutdown.")
  (prodigy-define-service
    :name "lokesh1197@gmail.com-imap"
    :command "goimapnotify"
    :args (list "-conf" (expand-file-name "goimapnotify/lokesh1197@gmail.com.json" (getenv "XDG_CONFIG_HOME")))
    :tags '(email)
    :kill-signal 'sigkill)
  (prodigy-define-service
    :name "lokesh1197@yahoo.com-imap"
    :command "goimapnotify"
    :args (list "-conf" (expand-file-name "goimapnotify/lokesh1197@yahoo.com.json" (getenv "XDG_CONFIG_HOME")))
    :tags '(email)
    :kill-signal 'sigkill)
  (prodigy-define-service
    :name "lokesh.mohanty@e-arc.com-imap"
    :command "goimapnotify"
    :args (list "-conf" (expand-file-name "goimapnotify/lokesh.mohanty@e-arc.com.json" (getenv "XDG_CONFIG_HOME")))
    :tags '(email)
    :kill-signal 'sigkill)
  (prodigy-define-service
    :name "random-wallpaper-every-10-min"
    :command "watch"
    :args (list "-n" "600" "feh --randomize --bg-fill ~/Pictures/Wallpapers/*")
    :tags '(desktop)
    :kill-signal 'sigkill))

(use-package docker)

(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)

(setq-default indent-tabs-mode nil)

;; (define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)

(use-package aggressive-indent
  :custom (aggressive-indent-comments-too t))

(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom (highlight-indent-guides-method 'character))

(use-package vimish-fold
  :after evil)

(use-package evil-vimish-fold
  :after vimish-fold
  :init
  (setq evil-vimish-fold-mode-lighter " ???")
  :config
  (general-define-key
   :states 'normal
   :mode evil-vimish-fold-mode
   "zF" 'vimish-fold-avy)
  :hook ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode))

(defun my/project-ripgrep-consult ()
  "Start consult-ripgrep in the current project's root."
  (interactive)
  (consult-ripgrep (project-root (project-current t))))

(defun my/project-run-vterm ()
  "Invoke `vterm' in the project's root.
  Switch to the project specific term buffer if it already exists."
  (interactive)
  (let* ((path (project-root (project-current t)))
         (buffer (format "*%s %s*" "vterm" (directory-file-name path))))
    (unless (buffer-live-p (get-buffer buffer))
      (my/process-with-default-dir path
                                   (vterm buffer)))
    (popper-display-popup-at-bottom buffer)
    (switch-to-buffer-other-window buffer)
    ))

(defmacro my/process-with-default-dir (dir &rest body)
  "Invoke in DIR the BODY."
  (declare (debug t) (indent 1))
  `(let ((default-directory ,dir))
     ,@body))

;; (general-define-key
;;   ;; :states 'normal
;;   ;; "C-x pg"  ':ignore t
;;   ;; "C-x pgg" 'project-grep
;;   ;; "C-x pgr" 'my/project-ripgrep-consult
;;   ;; "C-x pt"  'my/project-run-vterm
;;   )

(my/leader-keys
  "mp"   '(:ignore t :which-key "+project")
  "mpg"  '(:ignore t :which-key "+search")
  "mpgg" '(project-grep :which-key "grep")
  "mpgr" '(my/project-ripgrep-consult :which-key "consult-ripgrep")
  "mpt"  '(my/project-run-vterm :which-key "vterm")
  )

(use-package flycheck
  :delight
  :hook (lsp-mode . flycheck-mode)
  ;; :bind (:map flycheck-mode-map
  ;;             ("M-p" . flycheck-previous-error)
  ;;             ("M-n" . flycheck-next-error))
  :custom
  (flycheck-disable-checker 'typescript-tslint)
  (flycheck-enable-checker 'javascript-eslint)
  (flycheck-display-errors-delay .3)
  )

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package lsp-mode
  :hook ((latex-mode js2-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-l")
  :config
  (lsp-enable-which-key-integration t)
  )

(my/leader-keys
  "l"  '(:ignore t :which-key "lsp")
  ;; "ld" 'xref-find-definitions
  ;; "lr" 'xref-find-references
  "ln" 'lsp-ui-find-next-reference
  "lp" 'lsp-ui-find-prev-reference
  ;; "ls" 'counsel-imenu
  "le" 'lsp-ui-flycheck-list
  ;; "lS" 'lsp-ui-sideline-mode
  ;; "lX" 'lsp-execute-code-action
  )

(use-package lsp-ui
  ;; :after lsp
  ;; :hook (lsp-mode . lsp-ui-mode)
  ;; :custom
  ;; ;; (lsp-ui-sideline-enable t)
  ;; ;; (lsp-ui-sideline-show-hover nil)
  ;; (lsp-ui-doc-position 'bottom)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  ;; (lsp-ui-doc-show)
)

(use-package lsp-treemacs
  :after (lsp treemacs)
  :config
  (lsp-treemacs-sync-mode 1))

(my/leader-keys
  "lt"  '(:ignore t :which-key "treemacs")
  "lte" 'lsp-treemacs-errors-list
  "lts" 'lsp-treemacs-symbols
  "ltf" 'lsp-treemacs-quick-fix
  "lti" 'lsp-treemacs-implementations
  )

(use-package consult-lsp
  ;; :commands (consult-lsp-diagnostics consult-lsp-symbols)
)

(my/leader-keys
  "lc"  '(:ignore t :which-key "consult")
  "lcd" 'consult-lsp-diagnostics
  "lcs" 'consult-lsp-symbols
  "lcf" '=consult-lsp-file-symbols
  )

;; Use the following line to replace xref-find-apropos in lsp-mode controlled buffers:
;; (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols)

;; (use-package dap-mode
;;   :after lsp-mode
;;   ;; Hide all dap-ui buffers
;;   :custom
;;   (lsp-enable-dap-auto-configure nil)

;;   :config
;;   (dap-ui-mode 1)       ;; show basic ui
;;   (dap-tooltip-mode 1)  ;; show tooltip

;;   ;; Setup debugging for node
;;   (require 'dap-node)
;;   ;; (require 'dap-node-terminal)
;;   ;; (require 'dap-firefox)
;;   ;; (require 'dap-chrome)
;;   ;; (dap-node-setup)

;;   (add-hook 'dap-stopped-hook
;;             (lambda (arg) (call-interactively #'dap-hydra)))

;;   ;; Bind `C-c l d` to `dap-hydra` for easy access
;;   (general-define-key
;;    :keymaps 'lsp-mode-map
;;    :prefix lsp-keymap-prefix
;;    "d" '(dap-hydra t :wk "debugger"))
;; )

;; (defun my/download-dap-node ()
;;   "Downloads vscode-node-debug2 from github and sets it up in the right path"
;;   (interactive)
;;   (async-shell-command (concat "cd ~/.config/emacs/var/dap/extensions/vscode"
;;                                " && aria2c https://codeload.github.com/microsoft/vscode-node-debug2/tar.gz/refs/tags/v1.43.0"
;;                                " && tar -xvf vscode-node-debug2-1.43.0.tar.gz"
;;                                " && mv vscode-node-debug2-1.43.0 extension"
;;                                " && mv extension ms-vscode.node-debug2/"
;;                                " && cd ms-vscode.node-debug2/extension"
;;                                " && npm i && npm run build")))

(use-package js2-mode
  :mode "\\.js\\'"
  :hook ((js2-mode . js2-imenu-extras-mode)
         (js2-mode . lsp-deferred))
  :custom (js-indent-level 2)
  ;; :config (flycheck-add-mode 'javascript-eslint 'js2-mode)
)

;; (use-package prettier-js
;;   :delight
;;   :custom (prettier-js-args '("--print-width" "100"
;;                               "--single-quote" "true"
;;                               "--trailing-comma" "all")))

(use-package typescript-mode
  :hook ((typescript-mode . lsp-deferred))
  :mode ("\\.\\(ts\\|tsx\\)\\'")
  :custom
  ;; (lsp-clients-typescript-server-args '("--stdio" "--tsserver-log-file" "/dev/stderr"))
  (typescript-indent-level 2)
  :config
  (flycheck-add-mode 'javascript-eslint 'typescript-mode)
)

(setq lsp-clients-angular-language-server-command
      '("node"
        "/home/lokesh/.nvm/versions/node/v14.16.0/lib/node_modules/@angular/language-server"
        "--ngProbeLocations"
        "/home/lokesh/.nvm/versions/node/v14.16.0/lib/node_modules"
        "--tsProbeLocations"
        "/home/lokesh/.nvm/versions/node/v14.16.0/lib/node_modules"
        "--stdio"))

(use-package dockerfile-mode :delight "??" :mode "Dockerfile\\'")

(use-package json-mode
  ;; :mode "\\.json\\'"
      )

(use-package markdown-mode
  :delight "??"
  ;; :ensure-system-package (pandoc . "yay -S pandoc")
  :mode ("\\.\\(md\\|markdown\\)\\'")
  :custom (markdown-command "/usr/bin/pandoc"))

(use-package markdown-preview-mode
  :commands markdown-preview-mode
  :custom
  (markdown-preview-javascript
   (list (concat "https://github.com/highlightjs/highlight.js/"
                 "9.15.6/highlight.min.js")
         "<script>
            $(document).on('mdContentChange', function() {
              $('pre code').each(function(i, block)  {
                hljs.highlightBlock(block);
              });
            });
          </script>"))
  (markdown-preview-stylesheets
   (list (concat "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/"
                 "3.0.1/github-markdown.min.css")
         (concat "https://github.com/highlightjs/highlight.js/"
                 "9.15.6/styles/github.min.css")

         "<style>
            .markdown-body {
              box-sizing: border-box;
              min-width: 200px;
              max-width: 980px;
              margin: 0 auto;
              padding: 45px;
            }

            @media (max-width: 767px) { .markdown-body { padding: 15px; } }
          </style>")))

(use-package yaml-mode
  :delight "??"
  :hook (yaml-mode . lsp-deferred)
  :mode ("\\.\\(yaml\\|yml\\)\\'"))

(use-package sql-mode
  :straight (:type built-in)
  ;; :ensure-system-package (sqls . "yay -S sqls")
  :mode "\\.sql\\'")

(use-package sql-indent
  :delight sql-mode "??"
  :hook (sql-mode . sqlind-minor-mode))

(use-package haskell-mode
  :mode "\\.hs\\'"
  ;; :hook ((haskell-mode . lsp-deferred))
  )

;; (require 'lsp)
;; (require 'lsp-haskell)

;; (add-hook 'haskell-mode-hook #'lsp)
;; (add-hook 'haskell-literate-mode-hook #'lsp)

(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)

(my/leader-keys
  "e"   '(:ignore t :which-key "eval")
  "e b"   '(eval-buffer :which-key "Eval elisp in buffer")
  "e d"   '(eval-defun :which-key "Eval defun")
  "e e"   '(eval-expression :which-key "Eval elisp expression")
  "e l"   '(eval-last-sexp :which-key "Eval last sexression"))

(my/leader-keys
  :keymaps '(visual)
  "e r" '(eval-region :which-key "eval region"))

;; TODO: This causes issues for some reason.
;; :bind (:map geiser-mode-map
;;        ("TAB" . completion-at-point))

(use-package geiser
  :config
  ;; (setq geiser-default-implementation 'gambit)
  ;; (setq geiser-active-implementations '(gambit guile))
  ;; (setq geiser-implementations-alist '(((regexp "\\.scm$") gambit)
  ;;                                      ((regexp "\\.sld") gambit)))
  ;; (setq geiser-repl-default-port 44555) ; For Gambit Scheme
  (setq geiser-default-implementation 'guile)
  (setq geiser-active-implementations '(guile))
  ;; (setq geiser-repl-default-port 44555) ; For Gambit Scheme
  (setq geiser-implementations-alist '(((regexp "\\.scm$") guile))))

(use-package geiser-guile)

(use-package sh-script
  :straight (:type built-in)
  ;; :hook (after-save . executable-make-buffer-file-executable-if-script-p)
)

(use-package dart-mode
  :hook ((dart-mode . lsp-deferred)
         (dart-mode . flutter-test-mode)
  ))

(use-package lsp-dart)

(setq read-process-output-max (* 1024 1024)
      company-minimum-prefix-length 1
      lsp-lens-enable t
      lsp-signature-auto-activate nil)

(use-package flutter
  :after dart-mode
  :bind (:map dart-mode-map
              ("C-M-x" . #'flutter-run-or-hot-reload))
  ;; :custom
  ;; (flutter-sdk-path "/Applications/flutter/")
  )

(use-package hover
  :after dart-mode
  :bind (:map dart-mode-map
              ("C-M-z" . #'hover-run-or-hot-reload)
              ("C-M-r" . #'hover-run-or-hot-restart)
              ("C-M-p" . #'hover-take-screenshot))
  ;; :general
  ;; (:states 'normal
  ;;    :keymaps 'dart-mode-map
  ;;    "SPC m h r" 'hover-run-or-hot-reload
  ;;    "SPC m h x" 'hover-run-or-hot-restart
  ;;    "SPC m h p" 'hover-take-screenshot)
  ;; :init
  ;; (setq hover-flutter-sdk-path (concat (getenv "HOME") "/flutter") ; remove if `flutter` is already in $PATH
  ;;       hover-command-path (concat (getenv "GOPATH") "/bin/hover") ; remove if `hover` is already in $PATH
  ;;       hover-hot-reload-on-save t
  ;;       hover-screenshot-path (concat (getenv "HOME") "/Pictures")
  ;;       hover-screenshot-prefix "my-prefix-"
  ;;       hover-observatory-uri "http://my-custom-host:50300"
  ;;       hover-clear-buffer-on-hot-restart t)
  )

;; (use-package ccls
;;   :hook ((c-mode c++-mode objc-mode cuda-mode) .
;;          (lambda () (require 'ccls) (lsp))))

;; (use-package lispy
;;   :hook ((emacs-lisp-mode . lispy-mode)
;;          (scheme-mode . lispy-mode)))

;; ;; (use-package evil-lispy
;; ;;   :hook ((lispy-mode . evil-lispy-mode)))

;; (use-package lispyville
;;   :hook ((lispy-mode . lispyville-mode))
;;   :config
;;   (lispyville-set-key-theme '(operators c-w additional
;;                               additional-movement slurp/barf-cp
;;                               prettify)))

;; (use-package web-mode
;;   :mode "(\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'"
;;   :config
;;   (setq-default web-mode-code-indent-offset 2)
;;   (setq-default web-mode-markup-indent-offset 2)
;;   (setq-default web-mode-attribute-indent-offset 2))

;; ;; 1. Start the server with `httpd-start'
;; ;; 2. Use `impatient-mode' on any buffer
;; (use-package impatient-mode)

;; (use-package skewer-mode)

;; (use-package python-mode
;;   :hook (python-mode . lsp-deferred)
;;   :custom
;;   ;; NOTE: Set these if Python 3 is called "python3" on your system!
;;   ;; (python-shell-interpreter "python3")
;;   ;; (dap-python-executable "python3")
;;   (dap-python-debugger 'debugpy)
;;   :config
;;   (require 'dap-python))

;; (use-package python
;;   :straight flycheck
;;   :delight "??"
;;   :preface
;;   (defun python-remove-unused-imports()
;;     "Remove unused imports and unused variables with autoflake."
;;     (interactive)
;;     (if (executable-find "autoflake")
;;         (progn
;;           (shell-command (format "autoflake --remove-all-unused-imports -i %s"
;;                                  (shell-quote-argument (buffer-file-name))))
;;           (revert-buffer t t t))
;;       (warn "[???] python-mode: Cannot find autoflake executable.")))
;;   :bind (:map python-mode-map
;;               ("M-[" . python-nav-backward-block)
;;               ("M-]" . python-nav-forward-block)
;;               ("M-|" . python-remove-unused-imports))
;;   :custom
;;   (flycheck-pylintrc "~/.pylintrc")
;;   (flycheck-python-pylint-executable "/usr/bin/pylint"))

;; (use-package lsp-pyright
;;   :if (executable-find "pyright")
;;   ;; To properly load `lsp-pyrigt', the `require' instruction is important.
;;   :hook (python-mode . (lambda ()
;;                          (require 'lsp-pyright)
;;                          (lsp-deferred)))
;;   :custom
;;   (lsp-pyright-python-executable-cmd "python3")
;;   (lsp-pyright-venv-path "~/.cache/pypoetry/virtualenvs/"))

;; (use-package blacken
;;   :delight
;;   :hook (python-mode . blacken-mode)
;;   :custom (blacken-line-length 79))

;; (use-package py-isort
;;   :hook ((before-save . py-isort-before-save)
;;          (python-mode . pyvenv-mode)))

;; (use-package pyvenv
;;   :after python
;;   :config
;;   (pyvenv-mode 1))

;; (use-package pyvenv
;;   :after python
;;   :custom
;;   (pyvenv-default-virtual-env-name (expand-file-name (format "%s/myenv/" xdg-data)))
;;   (pyvenv-workon (expand-file-name (format "%s/myenv/" xdg-data)))
;;   :config (pyvenv-tracking-mode))

;; requirements: emacs-web-socket, simple-httpd, zmq
;; (use-package jupyter)

(use-package ein)

;; (use-package tex
;;   :straight auctex
;;   :preface
;;   (defun my/switch-to-help-window (&optional ARG REPARSE)
;;     "Switches to the *TeX Help* buffer after compilation."
;;     (other-window 1))
;;   :hook (LaTeX-mode . reftex-mode)
;;   :bind (:map TeX-mode-map
;;               ("C-c C-o" . TeX-recenter-output-buffer)
;;               ("C-c C-l" . TeX-next-error)
;;               ("M-[" . outline-previous-heading)
;;               ("M-]" . outline-next-heading))
;;   :custom
;;   (TeX-auto-save t)
;;   (TeX-byte-compile t)
;;   (TeX-clean-confirm nil)
;;   (TeX-master 'dwim)
;;   (TeX-parse-self t)
;;   (TeX-PDF-mode t)
;;   (TeX-source-correlate-mode t)
;;   (TeX-view-program-selection '((output-pdf "PDF Tools")))
;;   :config
;;   (advice-add 'TeX-next-error :after #'my/switch-to-help-window)
;;   (advice-add 'TeX-recenter-output-buffer :after #'my/switch-to-help-window)
;;   ;; the ":hook" doesn't work for this one... don't ask me why.
;;   (add-hook 'TeX-after-compilation-finished-functions 'TeX-revert-document-buffer))

;; (setq-default TeX-engine 'xetex)

(use-package lsp-latex
  :if (executable-find "texlab")
  ;; To properly load `lsp-latex', the `require' instruction is important.
  :hook (LaTeX-mode . (lambda ()
                        (require 'lsp-latex)
                        (lsp-deferred)))
  :custom (lsp-latex-build-on-save t))

;; (use-package reftex
;;   :straight (:type built-in)
;;   :custom
;;   (reftex-save-parse-info t)
;;   (reftex-use-multiple-selection-buffers t))

;; (use-package bibtex
;;   :straight (:type built-in)
;;   :preface
;;   (defun my/bibtex-fill-column ()
;;     "Ensure that each entry does not exceed 120 characters."
;;     (setq fill-column 120))
;;   :hook ((bibtex-mode . lsp-deferred)
;;          (bibtex-mode . my/bibtex-fill-column)))

;; (use-package go-mode
;;   :hook (go-mode . lsp-deferred))

;; (use-package rust-mode
;;   :mode "\\.rs\\'"
;;   :init (setq rust-format-on-save t))

;; (use-package cargo
;;   :straight t
;;   :defer t)

;; (use-package csv-mode :mode ("\\.\\(csv\\|tsv\\)\\'"))

;; (use-package nov
;;   :mode ("\\.epub\\'" . nov-mode)
;;   :custom (nov-text-width 75))

;; (use-package gnuplot
;;   :mode "\\.\\(gp\\|gpi\\|plt\\)'"
;;   :bind (:map gnuplot-mode-map
;;               ("C-c C-c".  gnuplot-send-buffer-to-gnuplot)))

;; (use-package lua-mode :delight "??" :mode "\\.lua\\'")

;; (use-package nxml-mode
;;   :straight (:type built-in)
;;   :hook (nxml-mode . lsp-deferred)
;;   :mode ("\\.\\(xml\\|xsd\\|wsdl\\)\\'"))

;; (use-package edbi)
;; (use-package edbi-sqlite)

(use-package emmet-mode)

(use-package treemacs)

(with-eval-after-load 'treemacs
  (treemacs-resize-icons 20))

;; Add :after if needed
(use-package treemacs-evil)

;; show hidden files
;; (setq-default neo-show-hidden-files t)

(my/leader-keys 
  "d"    '(:ignore t :which-key "directory viewer")
  "d t"  '(treemacs-display-current-project-exclusively :which-key "treemacs")
  )

(use-package magit)
(my/leader-keys
  "g"      '(:ignore t :which-key "git")
  "g s"    '(magit-status :which-key "git status")
  "g l"    '(magit-log :which-key "git log")
  "g b"    '(magit-blame :which-key "git blame")
  )

(setq bare-git-dir (concat "--git-dir=" (expand-file-name "~/.cfg")))
(setq bare-work-tree (concat "--work-tree=" (expand-file-name "~")))

;; use magit on git bare repos like dotfiles repos
(defun my/magit-status-bare ()
  "set --git-dir and --work-tree in `magit-git-global-arguments' to `bare-git-dir' and `bare-work-tree' and calls `magit-status'"
  (interactive)
  (require 'magit-git)
  (add-to-list 'magit-git-global-arguments bare-git-dir)
  (add-to-list 'magit-git-global-arguments bare-work-tree)
  (call-interactively 'magit-status))

;; if you use `my/magit-status-bare' you cant use `magit-status' on other other repos 
;; you have to unset `--git-dir' and `--work-tree' use `my/magit-status' insted it unsets 
;; those before calling `magit-status'
(defun my/magit-status ()
  "sets the default value in `magit-git-global-arguments' and calls `magit-status'"
  (interactive)
  (require 'magit-git)
  (setq-default magit-git-global-arguments (eval (car (get 'magit-git-global-arguments 'standard-value)))))

;; (use-package forge)

;; (setq forge-alist (append forge-alist '(("arc-bitbucket.org" "api.bitbucket.org/2.0" "bitbucket.org" forge-bitbucket-repository))))

;; (use-package perspective
;;   :bind
;;   ("C-x C-b" . persp-list-buffers)   ; or use a nicer switcher, see below
;;   :config
;;   (persp-mode))

;; (use-package restclient
;;   :defer t
;;   :mode (("\\.http\\'" . restclient-mode))
;;   :bind (:map restclient-mode-map
;;               ("C-c C-f" . json-mode-beautify)))

(use-package verb
  :custom
  (verb-trim-body-end "[ \t\n\r]+")
)

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package org
  ;; :straight org-contrib
  :config
  (setq org-modules '(
                      org-crypt
                      org-agenda
                      org-habit
                      ;; org-bookmark
                      ;; org-eshell
                      ;; org-irc
                      ))
  (add-hook 'org-mode-hook 'org-indent-mode)
  (setq org-directory "~/Org/")
  (setq org-ellipsis " ???"
        org-hide-emphasis-markers t     ;; hide rich text markers      
        org-hide-block-startup nil
        ;; org-hide-block-startup nil
        org-startup-folded t
        org-cycle-separator-lines 2
        org-capture-bookmark nil

        org-startup-indented t

        ;; Org Source indentation
        org-src-fontify-natively t       
        org-src-tab-acts-natively nil     ;; setting it to t cause error in yasnippet expansion
        ;; org-edit-src-content-indentation 2
        ;; org-src-preserve-indentation nil
        ;; org-fontify-quote-and-verse-blocks t
        org-confirm-babel-evaluate nil
        ;; org-pretty-entities t        ;; set pretty entities by default
        )
)    

;; (set-default 'preview-scale-function 1.2)

  (my/leader-keys 
    "m"      '(:ignore t :which-key "Mode Specific Bindings")
    "m t"      '(org-toggle-link-display :which-key "Toggle the display of link")
    )

(defun efs/org-babel-tangle-config()
  ;; (when (string-equal (file-name-directory (buffer-file-name))
  ;;                     (expand-file-name user-emacs-directory))
  (when (string-equal (buffer-file-name)
                      (expand-file-name "config.org" user-emacs-directory))
    ;; Dynamic scoping
    (let ((org-confirm-babel-evalute nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(org-babel-do-load-languages
  'org-babel-load-languages
      '((C          . t)
        (python     . t)
        (emacs-lisp . t)
        (shell      . t)
        (latex      . t)
        (js         . t)
        (octave     . t)
        (sql        . t)
        (ditaa      . t)))

;; (with-eval-after-load 'org
;;   (org-babel-do-load-languages
;;       'org-babel-load-languages
;;       '((emacs-lisp . t)
;;       (python . t)))

;;   (push '("conf-unix" . conf-unix) org-src-lang-modes))

(setq org-highest-priority ?A
      org-default-priority ?C
      org-lowest-priority ?E)

(setq org-todo-keywords 
      '(
        (sequence "TODO(t@/!)" "ACTIVE(a!)" "BACKLOG(b!)" "HOLD(h@/!)" "|" "DONE(D!)")
        (sequence "WAITING(w@/!)" "DELEGATED(d@/!)" "|" "ASSIGNED(A@/!)" "CANCELLED(C@/!)")
        (sequence "CONSUME(c!)" "CONSUMING(k!)" "SHARE(s@/!)" "|" "IGNORED(I@/!)" "REFERENCE(R!)" "SHARED(S!)")
        (sequence "VISIT(v!)" "|" "VISITED(V!)")  ;; physically
        (sequence "|" "NOTE(N)" "BOOKMARK(B)")  ;; static todo keywords
        ))

;; (setq org-agenda-files '(
;;                          "~/Org/Agenda.org"
;;                          "~/Org/Tasks.org"
;;                          "~/Org/Journal.org"
;;                          "~/Org/Anniversaries.org"
;;                          "~/Org/Habits.org"
;;                          "~/Org/References.org"
;;                          "~/Org/Work.org"
;;                          ))
(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)

(setq org-log-reschedule 'note)
(setq org-log-redeadline 'note)
;; (setq org-log-clock-out 'note)
;; (setq org-log-refile 'note)
;; (setq org-log-note-clock-out t)
;; (setq org-trest-insert-todo-heading-as-state-change t) ;; log inserting a heading

;; Configure custom agenda views
(setq org-agenda-custom-commands
      '(("d" "Dashboard"
         ((agenda "" ((org-deadline-warning-days 7)))
          (todo "TODO"
                ((org-agenda-overriding-header "Tasks")))
          (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

        ("T" "Tasks" tags "-STYLE=\"habit\"")
        ;; ("t" "Tasks" tags "+TODO={.*}&-STYLE=\"habit\"")

        ("h" "Habits" tags "+STYLE=\"habit\"")

        ("b" "Backlogs"
         ((todo "BACKLOG"
                ((org-agenda-overriding-header "Backlog Tasks")))))

        ("R" "References to visit/consume" tags-todo "+CONSUME")

        ;; Low-effort next actions
        ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
         ((org-agenda-overriding-header "Low Effort Tasks")
          (org-agenda-max-todos 20)
          (org-agenda-files org-agenda-files)))

        ("w" "Office Status"
         ((tags "+@work+TODO=\"TODO\""
                ((org-agenda-overriding-header "TODO")
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"ACTIVE\""
                ((org-agenda-overriding-header "Active Projects")
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"BACKLOG\""
                ((org-agenda-overriding-header "Todo when I am free")
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"WAITING\""
                ((org-agenda-overriding-header "Waiting")
                 (org-agenda-todo-list-sublevels nil)
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"DELEGATED\""
                ((org-agenda-overriding-header "Delegated to some one else")
                 (org-agenda-todo-list-sublevels nil)
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"ASSIGNED\""
                ((org-agenda-overriding-header "Assigned")
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"COMPLETED\+TODO=\"DONE\""
                ((org-agenda-overriding-header "Completed Projects")
                 (org-agenda-files org-agenda-files)))
          (tags "+@work+TODO=\"CANCELED\""
                ((org-agenda-overriding-header "Cancelled Projects")
                 (org-agenda-files org-agenda-files)))))))

;; (require 'org-habit)
;; (add-to-list 'org-modules 'org-habit)
;; (setq org-habit-graph-column 60)
(defun org-todo-at-date (date)
  (interactive (list (org-time-string-to-time (org-read-date))))
  (cl-flet ((org-current-effective-time (&rest r) date)
            (org-today (&rest r) (time-to-days date)))
    (org-todo)))

(setq org-tag-alist
      '((:startgroup)
        ;; Enter mutually exclusive groups here
        (:endgroup)
        (:startgrouptag)
        ("@work" . ?W)
        (:grouptags)
        ("new-gen" . ?N)
        ("idm" . ?I)
        ("appplication" . ?A)
        ("equipment" . ?E)
        (:endgrouptag)
        ("org-config" . ?o)
        ("agenda" . ?a)
        ("planning" . ?p)
        ("note" . ?n)
        ("idea" . ?i)))

;; (defun org-find-month-in-datetree()
;;   (org-datetree-find-date-create (calendar-current-date))
;;   (kill-line))

(setq org-capture-templates 
      `(("t" "Tasks")
        ("tt" "General Task" entry 
         (file+olp "~/Org/Tasks.org" "Inbox")
         "* TODO %? %^G\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)
        ("ts" "Scheduled Task" entry 
         (file+olp "~/Org/Tasks.org" "Inbox")
         "* TODO %? %^G\nSCHEDULED: %^t\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)
        ("td" "Task with deadline" entry 
         (file+olp "~/Org/Tasks.org" "Inbox")
         "* TODO %? %^G\nDEADLINE: %^t\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)

        ("w" "Work Tasks")
        ("wt" "Task" entry 
         (file+olp "~/Org/Work.org" "INBOX")
         "* TODO %? %^G:@work:\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)
        ("ws" "Scheduled Task" entry 
         (file+olp "~/Org/Work.org" "INBOX")
         "* TODO %? %^G:@work:\nSCHEDULED: %^t\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)
        ("wd" "Task with deadline" entry 
         (file+olp "~/Org/Work.org" "INBOX")
         "* TODO %? %^G:@work:\nDEADLINE: %^t\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i" 
         :empty-lines 1)
        ("wn" "Work Note" entry 
         (file+olp "~/Org/Work.org" "NOTES")
         "* NOTE %? :@work\n:PROPERTIES:\n:CATEGORIES: %^{Categories}\n:Created: %U\n:LOCATION: %a\n:END:\n  %i")

        ("b" "Bookmarks / References")
        ("bl" "Links to visit" entry 
         (file+olp "~/Org/References.org" "Links")
         "* CONSUME [[%c][%^{Link Title}]] %^G\n:PROPERTIES:\n:Created: %U\n:END:\n  %i" 
         :empty-lines 1)
        ("bb" "Bookmark" entry 
         (file+olp "~/Org/References.org" "Bookmarks")
         "* BOOKMARK [[%c][%^{Link Title}]] %^G\n:PROPERTIES:\n:Created: %U\n:REPEAT_TO_STATE: BOOKMARK\n:LOGGING: DONE(!)\n:END:\n  %i")
        ("bb" "Bookmark" entry 
         (file+olp "~/Org/References.org" "Bookmarks")
         "* BOOKMARK [[%c][%^{Link Title}]] %^G\n:PROPERTIES:\n:Created: %U\n:REPEAT_TO_STATE: BOOKMARK\n:LOGGING: DONE(!)\n:END:\n  %i")

        ("n" "Notes")
        ("nn" "General Note" entry 
         (file "~/Org/Notes.org")
         "* NOTE %? %^G\n:PROPERTIES:\n:Created: %U\n:LOCATION: %a\n:END:\n  %i")
        ("nv" "Vocabulary" entry 
         (file+olp+datetree "~/Org/Notes/Vocabulary.org")
         "\n* %<%I:%M %p>\n%?\n"
         :clock-in :clock-resume :empty-lines 0)

        ("j" "Journal Entries")
        ("jj" "Journal" entry
         (file+olp+datetree "~/Org/Journal.org")
         "\n* %<%I:%M %p> - %? :journal:\n"
         :clock-in :clock-resume :empty-lines 1)

        ("h" "Habit Entries")
        ("hd" "Daily Habit" entry
         (file+olp "~/Org/Habits.org" "Daily Habits")
         "* TODO %?\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:STYLE:    habit\n:Created: %U\n:END:\n"
         :empty-lines 1)
        ("hw" "Weekly Habit" entry
         (file+olp "~/Org/Habits.org" "Weekly Habits")
         "* TODO %?\nSCHEDULED: <%<%Y-%m-%d %a .+1w>>\n:PROPERTIES:\n:STYLE:    habit\n:Created: %U\n:END:\n"
         :empty-lines 1)
        ("hm" "Monthly Habit" entry
         (file+olp "~/Org/Habits.org" "Monthly Habits")
         "* TODO %?\nSCHEDULED: <%<%Y-%m-%d %a .+1m>>\n:PROPERTIES:\n:STYLE:    habit\n:Created: %U\n:END:\n"
         :empty-lines 1)
        ("hy" "Yearly Habit" entry
         (file+olp "~/Org/Habits.org" "Yearly Habits")
         "* TODO %?\nSCHEDULED: <%<%Y-%m-%d %a .+1y>>\n:PROPERTIES:\n:STYLE:    habit\n:Created: %U\n:END:\n"
         :empty-lines 1)
        ("hr" "Repeat Tasks" entry 
         (file "~/Org/Habits.org")
         "* REPEAT %?\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:Created: %U\n:STYLE: habit\n:REPEAT_TO_STATE: REPEAT\n:LOGGING: DONE(!)\n:ARCHIVE: %%s_archive::* Habits\n:END:\n")

        ("P" "process-soon" entry 
         (file+headline "todo.org" "Todo")
         "* TODO %:fromname: %a %?\nDEADLINE: %(org-insert-time-stamp (org-read-date nil t \"+2d\"))")

        ("m" "Metrics Capture")
        ("mw" "Weight" table-line (file+headline "~/Org/Metrics.org" "Weight")
         "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)
        ))

(setq org-refile-targets '(
                           (nil :maxlevel . 1)
                           (org-agenda-files :maxlevel . 1)
                           ("Archive.org" :maxlevel . 1)
                           ;; ("Tasks.org" :maxlevel . 1)
                           ))

;; Save Org buffers after refiling!
(advice-add 'org-refile :after 'org-save-all-org-buffers)

(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme '(navigation todo insert textobjects additional))
  ;; (setq org-special-ctrl-a/e t)
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; An example of how this works.
;; [[arch-wiki:Name_of_Page][Description]]
;; This overwrites the default list
(setq org-link-abbrev-alist 
      '(("google"         . "http://www.google.com/search?q=")
        ("ddg"            . "https://duckduckgo.com/?q=")
        ("stack-exchange" . "https://emacs.stackexchange.com/a/")
        ("github"         . "https://github.com/")
        ("wiki"           . "https://en.wikipedia.org/wiki/")))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  ;; toggle links
  (org-appear-autolinks t) 
  ;; toggle subscripts and superscripts
  (org-appear-autosubmarkers t)
  ;; toggle org entities
  (org-appear-autoentities t)
  ;; toggle keywords in org-hidden-keywords
  (org-appear-autokeywords t)
  ;; delay toggle by 0.5 seconds
  (org-appear-delay 0.5)
)

(use-package toc-org
  :after org
  :hook (org-mode . toc-org-enable))

(use-package org-crypt
  :after org
  :straight (:type built-in)
  :config (org-crypt-use-before-save-magic)
  :custom (org-crypt-key "C40959B80457F5A83E886FB429D0512FC8D22444"))

(setq epa-file-encrypt-to "lokesh1197@yahoo.com")
(setq epa-file-select-keys "auto")

(defvar my/org-roam-project-template
  '("p" "project" plain "** TODO %?"
    :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                           "#+title: ${title}\n#+category: ${title}\n#+filetags: Project\n"
                           ("Tasks"))))

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

;; similar to org roam node insert but doesn't take you to the new node
(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (push arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun my/org-roam-goto-month ()
  (interactive)
  (org-roam-capture- :goto (when (org-roam-node-from-title-or-alias (format-time-string "%Y-%B")) '(4))
                     :node (org-roam-node-create)
                     :templates '(("m" "month" plain "\n* Goals\n\n%?* Summary\n\n"
                                   :if-new (file+head "%<%Y-%B>.org"
                                                      "#+title: %<%Y-%B>\n#+filetags: Project\n")
                                   :unnarrowed t))))

(defun my/org-roam-goto-year ()
  (interactive)
  (org-roam-capture- :goto (when (org-roam-node-from-title-or-alias (format-time-string "%Y")) '(4))
                     :node (org-roam-node-create)
                     :templates '(("y" "year" plain "\n* Goals\n\n%?* Summary\n\n"
                                   :if-new (file+head "%<%Y>.org"
                                                      "#+title: %<%Y>\n#+filetags: Project\n")
                                   :unnarrowed t))))

(defun my/org-roam-capture-task ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Capture the new task, creating the project file if necessary
  (org-roam-capture- :node (org-roam-node-read nil
                                               ;; (my/org-roam-filter-by-tag "Project")
                                               (lambda (node)
                                                 (member "Project" (org-roam-node-tags node))))
                     :templates (list my/org-roam-project-template)))

;; add roam files with tag projects to agenda files
(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

(defhydra my/org-roam-jump-menu (:hint nil)
  "
^Goto^           ^Capture^       ^Jump^
^^^^^^^^-------------------------------------------------
_t_: today       _T_: today       _m_: current month
_r_: tomorrow    _R_: tomorrow    _e_: current year
_y_: yesterday   _Y_: yesterday   ^ ^
_d_: date        ^ ^              ^ ^
"
  ("t" org-roam-dailies-goto-today)
  ("r" org-roam-dailies-goto-tomorrow)
  ("y" org-roam-dailies-goto-yesterday)
  ("d" org-roam-dailies-goto-date)
  ("T" org-roam-dailies-capture-today)
  ("R" org-roam-dailies-capture-tomorrow)
  ("Y" org-roam-dailies-capture-yesterday)
  ("m" my/org-roam-goto-month)
  ("e" my/org-roam-goto-year)
  ("q" nil "quit"))

(use-package org-roam
  ;; :hook (after-init . org-roam-mode)
  :init
  ;; Hide update warning message
  (setq org-roam-v2-ack t)
  (setq my/daily-note-filename "%<%Y-%m-%d>.org"
        my/daily-note-header "#+title: %<%Y-%m-%d %a>\n\n[[roam:%<%Y-%B>]]\n\n")
  :custom
  (org-roam-directory "~/Org/Roam/")
  (org-roam-dailies-directory "~/Org/Journal/")
  (org-roam-completion-everywhere t)
  ;; (org-roam-graph-viewer "/usr/bin/qutebrowser")
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+author: Lokesh Mohanty\n#+filetags: %^G")
      :unnarrowed t)))

  (org-roam-dailies-capture-templates
   `(("d" "default" plain
      "* %?"
      :if-new (file+head ,my/daily-note-filename 
                         ,my/daily-note-header)
      :empty-lines 1)

     ("t" "task" entry
      "* TODO %?\n  %U\n  %a\n  %i"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Tasks"))
      :empty-lines 1)

     ("l" "log" plain
      "** %<%I:%M %p> - %?"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Log"))
      :empty-lines 1)

     ("j" "journal" entry
      "** %<%I:%M %p> - %^{Title}  :journal:\n\n%?\n\n"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Journal"))
      :empty-lines 1)

     ("m" "meeting" entry
      "** %<%I:%M %p> - %^{Meeting Title}  :meeting:\n\n%?\n\n"
      :if-new (file+head+olp ,my/daily-note-filename
                             ,my/daily-note-header
                             ("Meetings"))
      :empty-lines 1)))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n d" . my/org-roam-jump-menu/body)
         ("C-c n c" . org-roam-dailies-capture-today)
         ("C-c n t" . my/org-roam-capture-task)
         ("C-c n g" . org-roam-graph)
         :map org-mode-map
         (("C-c n i" . org-roam-node-insert)
          ("C-c n I" . org-roam-insert-immediate))
         )
  :config 
  (org-roam-db-autosync-enable)
  ;; (org-roam-db-autosync-mode)

  ;; Build the agenda list the first time for the session
  (my/org-roam-refresh-agenda-list)
  )

(use-package ox-reveal)

;; (use-package org-reveal
;;   :straight nil)

(use-package org-ql
  :after org)

;; ;; (use-package jupyter :straight nil :after org)
;; (use-package python :straight (:type built-in) :after org)
;; (use-package ob-C :straight (:type built-in) :after org)
;; (use-package ob-css :straight (:type built-in) :after org)
;; (use-package ob-dot :straight (:type built-in) :after org)
;; ;; (use-package ob-ein :straight (:type built-in) :after org)
;; (use-package ob-emacs-lisp :straight (:type built-in) :after org)
;; (use-package ob-gnuplot :straight (:type built-in) :after org)
;; (use-package ob-java :straight (:type built-in) :after org)
;; (use-package ob-js :straight (:type built-in) :after org)
;; (use-package ob-latex
;;   :straight (:type built-in)
;;   :after org
;;   :custom (org-latex-compiler "xelatex"))
;; (use-package ob-ledger :straight (:type built-in) :after org)
;; (use-package ob-makefile :straight (:type built-in) :after org)
;; (use-package ob-org :straight (:type built-in) :after org)
;; ;; (use-package ob-plantuml
;; ;;   :straight (:type built-in)
;; ;;   :after org
;; ;;   :custom (org-plantuml-jar-path (expand-file-name (format "%s/plantuml.jar" xdg-lib))))
;; (use-package ob-python :straight (:type built-in) :after org)
;; (use-package ob-shell :straight (:type built-in) :after org)
;; (use-package ob-sql :straight (:type built-in) :after org)

;; (use-package org-wild-notifier
;;   :after org
;;   :custom
;;   (alert-default-style 'libnotify)
;;   (org-wild-notifier-notification-title "Agenda Reminder")
;;   :config (org-wild-notifier-mode))

;; (use-package org-habit)
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  ;; ("???" "???" "???" "???" "???")
  :custom (org-bullets-bullet-list '("???")))
;; (add-hook 'org-mode-hook 'org-bullets-mode)

;; (setq org-alphabetical-lists t)

;; ;; Explicitly load required exporters
;; (require 'ox-html)
;; (require 'ox-latex)
;; (require 'ox-ascii)

;; ;; Enable using listings for code highlighting 
;; (setq org-latex-listings 't)

;; (with-eval-after-load 'ox-latex
;; (add-to-list 'org-latex-classes
;;              '("org-plain-latex"
;;                "\\documentclass{article}
;;            [NO-DEFAULT-PACKAGES]
;;            [PACKAGES]
;;            [EXTRA]"
;;                ("\\section{%s}" . "\\section*{%s}")
;;                ("\\subsection{%s}" . "\\subsection*{%s}")
;;                ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
;;                ("\\paragraph{%s}" . "\\paragraph*{%s}")
;;                ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; (setq org-blank-before-new-entry (quote ((heading . nil)
;;                                          (plain-list-item . nil))))

;; (use-package ox-man
;;   :straight (:type built-in))

;; Drag and drop images to org files
(use-package org-download
  :after org
  :config
  (setq-default org-download-image-dir "~/Pictures/Emacs")
  (add-hook 'dired-mode-hook 'org-download-enable)
)

(use-package mu4e
  ;; :defer 20 ; Wait until 20 seconds after startup
  :init
  (add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
  :straight
  ;;           ;; ( :host github 
  ;;           ;;   :repo "djcb/mu"  
  ;;           ;;   :branch "master"
  ;;           ;;   :files ("mu4e/*")   
  ;;           ;;   :pre-build (("./autogen.sh") ("make"))) 
              ( :host github :files ("build/mu4e/*.el") :repo "djcb/mu"
            :pre-build (("./autogen.sh")
                        ("ninja" "-C" "build")))
  ;; :custom   (mu4e-mu-binary (expand-file-name "mu/mu" (straight--repos-dir "mu")))) 
  :config
  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 15 60))
  (setq mu4e-get-mail-command "mbsync -c ~/.config/mu4e/mbsyncrc -aV")
  (setq mu4e-maildir "~/.local/share/mail")

  ;; Make sure that moving a message (like to Trash) causes the
  ;; message to get a new file name.  This helps to avoid the
  ;; dreaded "UID is N beyond highest assigned" error.
  ;; See this link for more info: https://stackoverflow.com/a/43461973
  (setq mu4e-change-filenames-when-moving t)

  ;; Use mu4e for sending e-mail
  (setq mail-user-agent 'mu4e-user-agent)
  ;; Use emacs for sending mail
  (setq message-send-mail-function 'smtpmail-send-it)

  ;; Make sure plain text mails flow correctly for recipents
  (setq mu4e-compose-format-flowed t)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)

  (setq mu4e-attachment-dir "~/Downloads")
  (setq mu4e-view-show-images t)

  ;; (setq mu4e-html2text-command "html2text -utf8 -nobs -width 72")
  ;; (setq mu4e-html2text-command "w3m -T text/html")
  ;; (add-to-list 'mu4e-view-actions '("ViewInBrowser" . mu4e-action-view-in-browser) t)

  ;; (setq mu4e-main-buffer-hide-personal-addresses t)
  ;; (setq starttls-use-gnutls t)

;; Set up contexts for email accounts
(setq mu4e-contexts
      `(,(make-mu4e-context
          :name "Gmail"
          :match-func (lambda (msg) (when msg
                                      (string-prefix-p "/lokesh1197@gmail.com" (mu4e-message-field msg :maildir))))
          :vars '(
                  (user-full-name . "Lokesh Mohanty")
                  (user-mail-address . "lokesh1197@gmail.com")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-stream-type . ssl)
                  (smtpmail-smtp-service . 465)
                  (mu4e-sent-folder . "/lokesh1197@gmail.com/[Gmail]/Sent Mail")
                  (mu4e-trash-folder . "/lokesh1197@gmail.com/[Gmail]/Trash")
                  (mu4e-drafts-folder . "/lokesh1197@gmail.com/[Gmail]/Drafts")
                  (mu4e-refile-folder . "/lokesh1197@gmail.com/[Gmail]/Archive")
                  ;; (mu4e-sent-messages-behavior . sent)
                  ))
        ,(make-mu4e-context
          :name "Yahoo"
          :match-func (lambda (msg) 
                        (when msg
                          (string-prefix-p "/lokesh1197@yahoo.com" (mu4e-message-field msg :maildir))))
          :vars '(
                  (user-full-name . "Lokesh Mohanty")
                  (user-mail-address . "lokesh1197@yahoo.com")
                  (smtpmail-smtp-server . "smtp.mail.yahoo.com")
                  (smtpmail-stream-type . ssl)
                  (smtpmail-smtp-service . 465)
                  (mu4e-sent-folder . "/lokesh1197@yahoo.com/Sent")
                  (mu4e-trash-folder . "/lokesh1197@yahoo.com/Trash")
                  (mu4e-drafts-folder . "/lokesh1197@yahoo.com/Drafts")
                  (mu4e-refile-folder . "/lokesh1197@yahoo.com/Archive")
                  ))
        ,(make-mu4e-context
          :name "Work"
          :match-func (lambda (msg) (when msg
                                      (string-prefix-p "/lokesh.mohanty@e-arc.com" (mu4e-message-field msg :maildir))))
          :vars '(
                  (user-full-name . "Lokesh Mohanty")
                  (user-mail-address . "lokesh.mohanty@e-arc.com")
                  (smtpmail-smtp-server . "smtp.office365.com")
                  (smtpmail-stream-type . starttls)
                  (smtpmail-smtp-service . 587)
                  (mu4e-sent-folder . "/lokesh.mohanty@e-arc.com/Sent Items")
                  (mu4e-trash-folder . "/lokesh.mohanty@e-arc.com/Deleted Items")
                  (mu4e-drafts-folder . "/lokesh.mohanty@e-arc.com/Drafts")
                  (mu4e-refile-folder . "/lokesh.mohanty@e-arc.com/Archive")
                  ))
        ,(make-mu4e-context
          :name "Befreier"
          :match-func (lambda (msg) 
                        (when msg
                          (string-prefix-p "/befreier19@gmail.com" (mu4e-message-field msg :maildir))))
          :vars '(
                  (user-full-name . "Lokesh Mohanty")
                  (user-mail-address . "befreier19@gmail.com")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-stream-type . ssl)
                  (smtpmail-smtp-service . 465)
                  (mu4e-sent-folder . "/befreier19@gmail.com/[Gmail]/Sent Mail")
                  (mu4e-trash-folder . "/befreier19@gmail.com/[Gmail]/Trash")
                  (mu4e-drafts-folder . "/befreier19@gmail.com/[Gmail]/Drafts")
                  (mu4e-refile-folder . "/befreier19@gmail.com/[Gmail]/Archive")
                  ))
        ,(make-mu4e-context
          :name "Ineffable"
          :match-func (lambda (msg) 
                        (when msg
                          (string-prefix-p "/ineffable97@gmail.com" (mu4e-message-field msg :maildir))))
          :vars '(
                  (user-full-name . "InEffable1197")
                  (user-mail-address . "ineffable97@gmail.com")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-stream-type . ssl)
                  (smtpmail-smtp-service . 465)
                  (mu4e-sent-folder . "/ineffable97@gmail.com/[Gmail]/Sent Mail")
                  (mu4e-trash-folder . "/ineffable97@gmail.com/[Gmail]/Trash")
                  (mu4e-drafts-folder . "/ineffable97@gmail.com/[Gmail]/Drafts")
                  (mu4e-refile-folder . "/ineffable97@gmail.com/[Gmail]/Archive")
                  ))
        ))
(setq mu4e-context-policy 'pick-first)

(defun my/mu4e-server ()
  "Start a server named 'other' for mail and chat"
  (interactive)
  (let ((server-name "other"))
    (server-start)))

(defun my-mu4e-choose-signature ()
  "Insert one of a number of signatures"
  (interactive)
  (let ((message-signature
         (mu4e-read-option "Signature:"
                           '(("formal" .
                              (concat
                               "Lokesh Mohanty\n"
                               "Software Engineer\n" 
                               "ARC Document Solutions\n"))
                             ("informal" .
                              "Lokesh Mohanty\n")))))
    (message-insert-signature)))

(add-hook 'mu4e-compose-mode-hook
          (lambda () (local-set-key (kbd "C-c C-w") #'my-mu4e-choose-signature)))

;; setup some handy shortcuts
(setq mu4e-maildir-shortcuts
      '(("/lokesh1197@gmail.com/Inbox"      . ?g)
        ("/lokesh1197@yahoo.com/Inbox"      . ?y)
        ("/befreier19@gmail.com/Inbox"    . ?b)
        ("/ineffable97@gmail.com/Inbox"   . ?i)
        ("/lokesh.mohanty@e-arc.com/Inbox"        . ?w)
        ("/lokesh.mohanty@e-arc.com/Sent Items"   . ?s)))

(add-to-list 'mu4e-bookmarks
             (make-mu4e-bookmark
              :name "My Work Inbox"
              :query "maildir:/lokesh.mohanty@e-arc.com/Inbox"
              :key ?w)
             (make-mu4e-bookmark
              :name "My Work Inbox Unread"
              :query "maildir:/lokesh.mohanty@e-arc.com/Inbox not flag:trashed"
              :key ?w))

(add-to-list
 'mu4e-bookmarks
 '("flag:unread NOT flag:trashed AND (flag:list OR from:lokesh1197@yahoo.com)"
   "Unread bulk messages" ?l))

;; (add-to-list
;;  'mu4e-bookmarks
;;  '("flag:unread NOT flag:trashed AND NOT flag:list AND (maildir:\"/royal holloway\" OR maildir:/INBOX)"
;;    "Unread messages addressed to me" ?i))

(add-to-list
 'mu4e-bookmarks
 '("mime:application/* AND NOT mime:application/pgp* AND (maildir:**/Inbox)"
   "Messages with attachments for me." ?d) t)

(add-to-list
 'mu4e-bookmarks
 '("flag:flagged"
   "Flagged messages" ?f) t)

(add-to-list
 'mu4e-bookmarks
 '("(maildir:\"lokesh1197@gmail.com/[Gmail]/Sent Mail\" OR maildir:\"lokesh1197@yahoo.com/Sent Mail\" OR mailir:\"lokesh.mohanty@e-arc.com/Sent Items\") AND date:7d..now"
   "Sent in last 7 days" ?s) t)

;; Prevent mu4e from permanently deleting trashed items
;; This snippet was taken from the following article:
;; http://cachestocaches.com/2017/3/complete-guide-email-emacs-using-mu-and-/
;; (defun remove-nth-element (nth list)
;;   (if (zerop nth) (cdr list)
;;     (let ((last (nthcdr (1- nth) list)))
;;       (setcdr last (cddr last))
;;       list)))
;; (setq mu4e-marks (remove-nth-element 5 mu4e-marks))
;; (add-to-list 'mu4e-marks
;;              '(trash
;;                :char ("d" . "???")
;;                :prompt "dtrash"
;;                :dyn-target (lambda (target msg) (mu4e-get-trash-folder msg))
;;                :action (lambda (docid msg target)
;;                          (mu4e~proc-move docid
;;                                          (mu4e~mark-check-target target) "-N"))))

;; Display options
;; (setq mu4e-view-show-images t)
;; (setq mu4e-view-show-addresses 't)

;; Composing mail
;; (setq mu4e-compose-dont-reply-to-self t)

;; Signing messages (use mml-secure-sign-pgpmime)
;; (setq mml-secure-openpgp-signers '("53C41E6E41AAFE55335ACA5E446A2ED4D940BF14"))

;; setup some handy shortcuts
;; you can quickly switch to your Inbox -- press ``ji''
;; then, when you want archive some messages, move them to
;; the 'All Mail' folder by pressing ``ma''.
(setq mu4e-maildir-shortcuts
      '(("/lokesh1197@gmail.com/Inbox"      . ?g)
        ("/lokesh1197@yahoo.com/Inbox"      . ?y)
        ("/lokesh.mohanty@e-arc.com/Inbox"        . ?w)
        ("/lokesh.mohanty@e-arc.com/Sent Items"   . ?s)))

;; (setq my/mu4e-inbox-query
;;       "(maildir:/lokesh1197@gmail.com/Inbox OR maildir:/lokesh.mohanty@e-arc.com/Inbox) AND flag:unread")

;; (defun my/go-to-inbox ()
;;   (interactive)
;;   (mu4e-headers-search my/mu4e-inbox-query))

;; (leader-key
;;   "m"  '(:ignore t :which-key "mail")
;;   "mm" 'mu4e
;;   "mc" 'mu4e-compose-new
;;   "mi" 'my/go-to-inbox
;;   "ms" 'mu4e-update-mail-and-index)

;; Start mu4e in the background so that it syncs mail periodically
;; Commented to prevent it from starting in all emacs sessions
;; (mu4e t)
)

;; (use-package mu4e-alert
;;   :hook ((after-init . mu4e-alert-enable-mode-line-display)
;;          (after-init . mu4e-alert-enable-notifications))
;;   :config 
;;   ;; Show unread emails from all inboxes
;;   ;; (setq mu4e-alert-interesting-mail-query my/mu4e-inbox-query)

;;   ;; Show notifications for mails already notified
;;   ;; (setq mu4e-alert-notify-repeated-mails nil)

;;   ;; Set notify-send for alert
;;   (mu4e-alert-set-default-style 'libnotify)
;;   (mu4e-alert-enable-notifications))

(use-package org-msg
  :after org
  :config
  (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t"
        org-msg-startup "hidestars indent inlineimages"
        org-msg-greeting-fmt "\nHi%s,\n\n"
        org-msg-recipient-names '(("lokesh.mohanty@e-arc.com" . "Lokesh Mohanty"))
        org-msg-greeting-name-limit 3
        org-msg-default-alternatives '((new		. (text html))
                                       (reply-to-html	. (text html))
                                       (reply-to-text	. (text)))
        org-msg-convert-citation t
        org-msg-signature (concat
                            "#+begin_signature\n"
                            "Regards,\n"
                            "*Lokesh Mohanty*\n"
                            "#+end_signature"))
  (org-msg-mode))

;; (use-package org-mime
;;   :config
;;   (setq org-mime-export-options 
;;         '(
;;           :section-numbers nil
;;           :with-author nil
;;           :with-toc nil))

;;   ;; Prompts whether to send email if the email is not htmlized
;;   (add-hook 'message-send-hook 'org-mime-confirm-when-no-multipart)
;;   ;; Automatically htmlize email before sending
;;   ;; (add-hook 'message-send-hook 'org-mime-htmlize)


;;   ;; Custom CSS
;;   (add-hook 'org-mime-html-hook
;;             (lambda ()
;;               (org-mime-change-element-style
;;                "pre" (format "color: %s; background-color: %s; padding: 0.5em;" 
;;                              "#E6E1DC" "#232323")))))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :init (pdf-tools-install :no-query))

(use-package pdf-view
  :straight (:type built-in)
  :after pdf-tools
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward)
              ("d" . pdf-annot-delete)
              ("h" . pdf-annot-add-highlight-markup-annotation)
              ("t" . pdf-annot-add-text-annotation))
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-view-resize-factor 1.1)
  ;; Avoid searching for unicodes to speed up pdf-tools.
  (pdf-view-use-unicode-ligther nil)
  ;; Enable HiDPI support, at the cost of memory.
  (pdf-view-use-scaling t))

(use-package wiki-summary
  :commands (wiki-summary wiki-summary-insert)
  ;; :bind ("C-c W" . wiki-summary)
  ;; :preface
  ;; (defun my/format-summary-in-buffer (summary)
  ;;   "Given a summary, sticks it in the *wiki-summary* buffer and displays
  ;;    the buffer."
  ;;   (let ((buf (generate-new-buffer "*wiki-summary*")))
  ;;     (with-current-buffer buf
  ;;       (princ summary buf)
  ;;       (fill-paragraph)
  ;;       (goto-char (point-min))
  ;;       (view-mode))
  ;;     (pop-to-buffer buf)))
  ;; :config
  ;; (advice-add 'wiki-summary/format-summary-in-buffer
  ;;             :override #'my/format-summary-in-buffer)
)

;; (use-package thesaurus
;;   :custom
;;   (thesaurus-prompt-mechanism 'dropdown-list)
;;   :config
;;   (setq thesaurus-bhl-api-key "8bf382e14f4a876ceebc0a6a93cfe499"))

(use-package powerthesaurus)

(use-package webpaste
  ;; :defer 0.4
  :bind (("C-c C-p C-b" . webpaste-paste-buffer)
         ("C-c C-p C-p" . webpaste-paste-buffer-or-region)
         ("C-c C-p C-r" . webpaste-paste-region))
  :custom (webpaste-provider-priority '("dpaste.org" "dpaste.com" "ix.io")))

(use-package imgbb
  :commands imgbb-upload
  :bind ("C-c C-p C-i" . imgbb-upload))

(use-package daemons
  :commands daemons)

(use-package elfeed
  :config
  (setq elfeed-search-feed-face ":foreground #fff :weight bold"
        elfeed-feeds (quote
                      (("http://nullprogram.com/feed/" nullprogram blog linux)
                       ;; ("https://www.reddit.com/r/linux.rss" reddit linux)
                       ;; ("https://www.reddit.com/r/commandline.rss" reddit commandline)
                       ;; ("https://www.reddit.com/r/emacs.rss" reddit emacs)
                       ;; ("https://www.gamingonlinux.com/article_rss.php" gaming linux)
                       ;; ("https://hackaday.com/blog/feed/" hackaday linux)
                       ;; ("https://opensource.com/feed" opensource linux)
                       ;; ("https://linux.softpedia.com/backend.xml" softpedia linux)
                       ;; ("https://itsfoss.com/feed/" itsfoss linux)
                       ;; ("https://www.zdnet.com/topic/linux/rss.xml" zdnet linux)
                       ;; ("https://www.phoronix.com/rss.php" phoronix linux)
                       ;; ("http://feeds.feedburner.com/d0od" omgubuntu linux)
                       ;; ("https://www.computerworld.com/index.rss" computerworld linux)
                       ;; ("https://www.networkworld.com/category/linux/index.rss" networkworld linux)
                       ;; ("https://www.techrepublic.com/rssfeeds/topic/open-source/" techrepublic linux)
                       ;; ("https://betanews.com/feed" betanews linux)
                       ;; ("http://lxer.com/module/newswire/headlines.rss" lxer linux)
                       ;; ("https://distrowatch.com/news/dwd.xml" distrowatch linux)
                       ))))

(use-package elfeed-goodies
  :init
  (elfeed-goodies/setup)
  :config
  (setq elfeed-goodies/entry-pane-size 0.5))

(use-package elfeed-org)
(use-package elfeed-dashboard)

(add-hook 'elfeed-show-mode-hook 'visual-line-mode)
(evil-define-key 'normal elfeed-show-mode-map
  (kbd "C-j") 'elfeed-goodies/split-show-next
  (kbd "C-k") 'elfeed-goodies/split-show-prev)
(evil-define-key 'normal elfeed-search-mode-map
  (kbd "C-j") 'elfeed-goodies/split-show-next
  (kbd "C-k") 'elfeed-goodies/split-show-prev)

(use-package tracking
  :defer t
  :config
  (setq tracking-faces-priorities '(all-the-icons-pink
                                    all-the-icons-lgreen
                                    all-the-icons-lblue))
  (setq tracking-frame-behavior nil))

;; ;; Add faces for specific people in the modeline.  There must
;; ;; be a better way to do this.
;; (defun dw/around-tracking-add-buffer (original-func buffer &optional faces)
;;   (let* ((name (buffer-name buffer))
;;          (face (cond ((s-contains? "Maria" name) '(all-the-icons-pink))
;;                      ((s-contains? "Alex " name) '(all-the-icons-lgreen))
;;                      ((s-contains? "Steve" name) '(all-the-icons-lblue))))
;;          (result (apply original-func buffer (list face))))
;;     (dw/update-polybar-telegram)
;;     result))

;; (defun dw/after-tracking-remove-buffer (buffer)
;;   (dw/update-polybar-telegram))

;; (advice-add 'tracking-add-buffer :around #'dw/around-tracking-add-buffer)
;; (advice-add 'tracking-remove-buffer :after #'dw/after-tracking-remove-buffer)
;; (advice-remove 'tracking-remove-buffer #'dw/around-tracking-remove-buffer)

;; ;; Advise exwm-workspace-switch so that we can more reliably clear tracking buffers
;; ;; NOTE: This is a hack and I hate it.  It'd be great to find a better solution.
;; (defun dw/before-exwm-workspace-switch (frame-or-index &optional force)
;;   (when (fboundp 'tracking-remove-visible-buffers)
;;     (when (eq exwm-workspace-current-index 0)
;;       (tracking-remove-visible-buffers))))

;; (advice-add 'exwm-workspace-switch :before #'dw/before-exwm-workspace-switch)

(use-package telega
  :commands telega
  :config
  (setq telega-user-use-avatars nil
        telega-use-tracking-for '(any pin unread)
        telega-chat-use-markdown-formatting t
        telega-emoji-use-images t
        telega-completing-read-function #'ivy-completing-read
        telega-msg-rainbow-title nil
        telega-chat-fill-column 75)
)

;; (use-package elcord
;;   :straight t
;;   :disabled dw/is-termux
;;   :custom
;;   (elcord-display-buffer-details nil)
;;   :config
;;   (elcord-mode))

(defun dw/on-erc-track-list-changed ()
  (dolist (buffer erc-modified-channels-alist)
    (tracking-add-buffer (car buffer))))

(use-package erc-hl-nicks
  :after erc)


(use-package erc-image
  :after erc)

(use-package erc
  :straight (:type built-in)
  :hook (erc-track-list-changed . dw/on-erc-track-list-changed)
  :config
  ;; (require 'erc-desktop-notifications)
  :custom
  (erc-nick "lokesh1197")
  (erc-user-full-name "Lokesh Mohanty")
  (erc-prompt-for-password nil)
  (erc-auto-query 'bury)
  (erc-join-buffer 'bury)
  (erc-track-shorten-start 8)
  (erc-interpret-mirc-color t)
  (erc-rename-buffers t)
  (erc-kill-buffer-on-part t)
  ;; erc-track-exclude '("#twitter_daviwil")
  ;; (erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE" "AWAY"))
  (erc-track-enable-keybindings nil)
  (erc-track-visibility 'selected-visible) ; Only use the selected frame for visibility
  (erc-track-exclude-server-buffer t)
  ;; (erc-fill-column 120)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 20)
  (erc-image-inline-rescale 300)
  (erc-server-reconnect-timeout 10)
  (erc-server-reconnect-attempts 5)
  (erc-autojoin-channels-alist '(("irc.libera.chat" "#systemcrafters" "#emacs" "#guix")))
  (erc-modules 
   '(netsplit fill button match track completion
              readonly networks ring autojoin noncommands
              irccontrols move-to-prompt stamp menu list autoaway
              smiley keep-place image hl-nicks))
  ;; (erc-quit-reason (lambda (s) (or s "Ejecting from cyberspace")))
  )

;; (add-hook 'erc-join-hook 'bitlbee-identify)
;; (defun bitlbee-identify ()
;;   "If we're on the bitlbee server, send the identify command to the &bitlbee channel."
;;   (when (and (string= "127.0.0.1" erc-session-server)
;;              (string= "&bitlbee" (buffer-name)))
;;     (erc-message "PRIVMSG" (format "%s identify %s"
;;                                    (erc-default-target)
;;                                    (password-store-get "IRC/Bitlbee")))))

(defun my/connect-irc ()
  (interactive)
  (erc-tls :server "irc.libera.chat" :port 6697 :nick "lokesh1197"))
;; (erc
;;    :server "127.0.0.1" :port 6667
;;    :nick "daviwil" :password (password-store-get "IRC/Bitlbee")))

;; Thanks karthik!
;; (defun erc-image-create-image (file-name)
;;   "Create an image suitably scaled according to the setting of
;; 'ERC-IMAGE-RESCALE."
;;   (let* ((positions (window-inside-absolute-pixel-edges))
;;         (width (- (nth 2 positions) (nth 0 positions)))
;;         (height (- (nth 3 positions) (nth 1 positions)))
;;         (image (create-image file-name))
;;         (dimensions (image-size image t))
;;         (imagemagick-p (and (fboundp 'imagemagick-types) 'imagemagick)))
;;                                         ; See if we want to rescale the image
;;     (if (and erc-image-inline-rescale
;;             (not (image-multi-frame-p image)))
;;         ;; Rescale based on erc-image-rescale
;;         (cond (;; Numeric: scale down to that size
;;               (numberp erc-image-inline-rescale)
;;               (if (> (cdr dimensions) erc-image-inline-rescale)
;;                   (create-image file-name imagemagick-p nil :height erc-image-inline-rescale)
;;                 image))
;;               (;; 'window: scale down to window size, if bigger
;;               (eq erc-image-inline-rescale 'window)
;;               ;; But only if the image is greater than the window size
;;               (if (or (> (car dimensions) width)
;;                       (> (cdr dimensions) height))
;;                   ;; Figure out in which direction we need to scale
;;                   (if (> width height)
;;                       (create-image file-name imagemagick-p nil :height  height)
;;                     (create-image file-name imagemagick-p nil :width width))
;;                 ;; Image is smaller than window, just give that back
;;                 image))
;;               (t (progn (message "Error: none of the rescaling options matched") image)))
;;       ;; No rescale
;;       image)))

;; (use-package 0x0
;;   :straight '(0x0 :host gitlab
;;                   :repo "willvaughn/emacs-0x0"))

;; (use-package plz
;;   :straight (plz :host github
;;                     :repo "alphapapa/plz.el"))

;; (use-package ement
;;   :straight (ement :host github
;;                     :repo "alphapapa/ement.el"))

(use-package elpher)

(use-package emojify
  ;; :hook (after-init . global-emojify-mode)
)

(setq auth-sources '("~/.authinfo.gpg" "~/.netrc"))

(defun efs/lookup-password (&rest keys)
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret))
      nil)))

(use-package password-store)

;; (use-package auth-source-pass
;;   :config
;;   (auth-source-pass-enable))

;; (use-package oauth2
;;   :straight t)

;; (leader-key
;;   "ap" '(:ignore t :which-key "pass")
;;   "app" 'password-store-copy
;;   "api" 'password-store-insert
;;   "apg" 'password-store-generate)

(use-package ledger-mode
  ;; :straight nil
  :preface
  (defun my/ledger-save ()
    "Clean the ledger buffer at each save."
    (interactive)
    (ledger-mode-clean-buffer)
    (save-buffer))
  :bind (:map ledger-mode-map
              ("C-x C-s" . my/ledger-save))
  :hook (ledger-mode . ledger-flymake-enable)
  :custom
  ;; (ledger-clear-whole-transactions t)
  (ledger-reconcile-default-commodity "INR")
  ;; (ledger-reports
  ;;  '(("account statement" "%(binary) reg --real [[ledger-mode-flags]] -f %(ledger-file) ^%(account)")
  ;;    ("balance sheet" "%(binary) --real [[ledger-mode-flags]] -f %(ledger-file) bal ^assets ^liabilities ^equity")
  ;;    ("budget" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:budget")
  ;;    ("budget goals" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget goals'")
  ;;    ("budget obligations" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget obligations'")
  ;;    ("budget debts" "%(binary) --empty -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^assets:bank ^assets:receivables ^assets:cash ^assets:'budget debts'")
  ;;    ("cleared" "%(binary) cleared [[ledger-mode-flags]] -f %(ledger-file)")
  ;;    ("equity" "%(binary) --real [[ledger-mode-flags]] -f %(ledger-file) equity")
  ;;    ("income statement" "%(binary) --invert --real -S -T [[ledger-mode-flags]] -f %(ledger-file) bal ^income ^expenses -p \"this month\""))
  ;;  (ledger-report-use-header-line nil))
  )

;; (use-package flycheck-ledger :after ledger-mode)

(use-package emacs-everywhere)

(use-package uuidgen
  :defer t)

(let ((file (expand-file-name "temporary.el" user-emacs-directory)))
  (if (file-exists-p file) (load-file file)))

;; (setq debug-on-error nil)
;; (setq debug-on-quit nil)

;; Make GC pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

;; (let ((elapsed (float-time (time-subtract (current-time)
;;                                           emacs-start-time))))
;;   (message "Loading settings...done (%.3fs)" elapsed))
;; (put 'narrow-to-region 'disabled nil)
