;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;;
;; This file only lists extra packages via `package!'. Doom manages
;; installation through straight.el, not package.el.

(package! org-roam-ui
  :recipe (:host github :repo "org-roam/org-roam-ui"))
(package! org-download)

(package! calfw)             ;; Calendar framework
(package! calfw-org)         ;; Org-mode integration for calendar

(package! org-super-agenda)
(package! org-ql)

(package! org-pomodoro)      ;; installed, but no use-package/keybinding in
                              ;; config.el right now — still reachable via
                              ;; M-x org-pomodoro. Say the word if you want it
                              ;; dropped entirely or wired back up.

(package! vterm)
(package! evil-tutor)

;; The following showed up in custom.el's `package-selected-packages' —
;; meaning they were installed via `package-install' rather than declared
;; here. That works locally, but a fresh `doom sync' on another machine (or
;; anyone cloning this repo) won't pull them in. Declaring them properly so
;; the config is actually reproducible:
(package! neotree)
(package! treemacs)
(package! treemacs-nerd-icons)
(package! ligature)
(package! indent-guide)
(package! smooth-scroll)
(package! fira-code-mode)
(package! zen-mode)
