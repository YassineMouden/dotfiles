;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;;
;; NOTE: this file only lists extra packages via `package!'. Doom manages
;; installation through straight.el, not package.el — a stray
;; `(require 'package)' / `(package-initialize)' block used to live here and


(package! org-roam-ui
  :recipe (:host github :repo "org-roam/org-roam-ui"))
(package! org-download)


(package! calfw)             ;; Calendar framework
(package! calfw-org)         ;; Org-mode integration for calendar


(package! org-super-agenda)
(package! org-ql)


(package! org-pomodoro)


(package! vterm)
(package! evil-tutor)
