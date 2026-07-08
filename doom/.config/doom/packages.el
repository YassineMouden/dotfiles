
;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.
;; See `package-archive-priorities` and `package-pinned-packages`.
;; Most users will not need or want to do this.
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; ============================================================================
;; SECOND BRAIN & KNOWLEDGE MANAGEMENT
;; ============================================================================

(package! org-roam-ui
  :recipe (:host github :repo "org-roam/org-roam-ui"))
(package! org-download)

;; ============================================================================
;; CALENDAR & SCHEDULING
;; ============================================================================

(package! calfw)             ;; Calendar framework
(package! calfw-org)         ;; Org-mode integration for calendar

;; ============================================================================
;; DAILY PLANNING & HABIT TRACKING
;; ============================================================================

(package! org-super-agenda)
(package! org-ql)

;; ============================================================================
;; PRODUCTIVITY
;; ============================================================================

(package! org-pomodoro)

;; ============================================================================
;; AESTHETICS
;; ============================================================================

(package! gruvbox-theme)

;; ============================================================================
;; UTILITIES
;; ============================================================================

(package! vterm)
(package! evil-tutor)

