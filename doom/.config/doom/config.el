;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ============================================================================
;; IDENTITY & APPEARANCE
;; ============================================================================

(setq user-full-name "Yacin"
      user-mail-address "jasinpr9915@gmail.com")

(setq doom-font (font-spec :family "Fira Code" :size 15)
      doom-variable-pitch-font (font-spec :family "Fira Code" :size 18)
      doom-big-font (font-spec :family "Fira Code" :size 22))

(setq doom-theme 'doom-gruvbox)
(setq display-line-numbers-type 'relative)

(when (display-graphic-p)
  (set-frame-parameter (selected-frame) 'alpha '(75. 75))
  (add-to-list 'default-frame-alist '(alpha . (70. 70))))

;; ============================================================================
;; CORE PATHS
;; ============================================================================

(setq org-directory "~/notes/")

(defvar soul-dir (concat org-directory "soul/"))
(defvar mind-dir (concat org-directory "mind/"))
(defvar roam-dir (concat org-directory "roam/"))
(defvar daily-dir (concat org-directory "daily/"))

(dolist (dir (list soul-dir mind-dir roam-dir daily-dir
                    (concat roam-dir "main/")
                    (concat roam-dir "code/")
                    (concat roam-dir "reference/")))
  (unless (file-exists-p dir)
    (make-directory dir t)))

;; ============================================================================
;; ORG-MODE: BASE CONFIGURATION
;; ============================================================================

(after! org
  (setq org-agenda-files
        (append (list org-directory
                      (concat org-directory "habits.org")
                      (concat org-directory "tasks.org"))
                (directory-files daily-dir t "\\.org$" nil)))

  (setq org-startup-indented t
        org-pretty-entities t
        org-hide-emphasis-markers t
        org-startup-with-inline-images t
        org-image-actual-width '(500)
        org-startup-folded 'content
        org-ellipsis " ▾"
        org-log-done 'time
        org-log-into-drawer t
        org-log-repeat 'time)

  (global-visual-line-mode t)

  ;; --- Habit tracking ---
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)

  (setq org-habit-show-habits t
        org-habit-show-habits-only-for-today nil
        org-habit-show-all-today t
        org-habit-show-done-always-green t
        org-habit-graph-column 50
        org-habit-preceding-days 21
        org-habit-following-days 7)

  ;; --- TODO keywords ---
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" "WAITING(w)" "|" "DONE(d!)" "CANCELLED(c)")
          (sequence "HABIT(h)" "|" "DONE(d!)")))

  (setq org-todo-keyword-faces
        '(("TODO" . (:foreground "#fb4934" :weight bold))
          ("NEXT" . (:foreground "#fabd2f" :weight bold))
          ("ACTIVE" . (:foreground "#b8bb26" :weight bold))
          ("HABIT" . (:foreground "#83a598" :weight bold))
          ("DONE" . (:foreground "#689d6a" :weight bold))))

  ;; --- Capture templates ---
  (setq org-capture-templates
        '(("i" "Inbox" entry
           (file "~/notes/inbox.org")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("t" "Task" entry
           (file+headline "~/notes/tasks.org" "Inbox")
           "* TODO %?\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("d" "Daily Note" entry
           (file (lambda () (concat daily-dir (format-time-string "%Y-%m-%d.org"))))
           (file "~/notes/.templates/daily-template.org")
           :empty-lines 0
           :immediate-finish t
           :jump-to-captured t)

          ("b" "Brain Dump" entry
           (file+headline
            (lambda () (concat daily-dir (format-time-string "%Y-%m-%d.org")))
            "Brain Dump")
           "* %?\nCaptured: %U\n"
           :empty-lines 1)

          ("h" "Habit" entry
           (file+headline "~/notes/habits.org" "Habits")
           "* HABIT %?\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: HABIT\n:END:\n"
           :empty-lines 1)

          ("r" "Random Thought" entry
           (file+headline (concat soul-dir "reflections.org") "Thoughts")
           "* %U - %?\n"
           :empty-lines 1)))

  ;; --- Refile ---
  (setq org-refile-targets
        '((("~/notes/tasks.org") :maxlevel . 3)
          (("~/notes/habits.org") :maxlevel . 2)
          (org-agenda-files :maxlevel . 3)))

  (setq org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm)

  ;; --- Agenda ---
  (setq org-agenda-span 'day
        org-agenda-start-on-weekday nil
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t)

  ;; Two views: plain todo list, and habit heatmap
  (setq org-agenda-custom-commands
        '(("t" "My TODOs"
           ((todo "NEXT")
            (todo "TODO")
            (todo "ACTIVE")
            (todo "WAITING")))

          ("h" "Habit Heatmap"
           ((agenda ""
                    ((org-agenda-span 'month)
                     (org-agenda-overriding-header "\nHabit Heatmap\n")))))))

  (setq org-archive-location (concat org-directory "archive/%s_archive::")))

;; ============================================================================
;; ORG-ROAM
;; ============================================================================

(use-package! org-roam
  :after org
  :init
  (setq org-roam-directory (file-truename "~/notes/roam/"))
  :config
  (org-roam-db-autosync-mode)

  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:30}" 'face 'org-tag)))

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                               "#+title: ${title}\n#+date: %U\n\n")
           :unnarrowed t))))

;; ============================================================================
;; AUTOMATIC DAILY NOTE CREATION
;; ============================================================================

(defun my/create-daily-note ()
  "Create or open today's daily note."
  (interactive)
  (let* ((daily-file (concat daily-dir (format-time-string "%Y-%m-%d.org")))
         (template-file "~/.doom.d/templates/daily-template.org"))
    (unless (file-exists-p daily-file)
      (when (file-exists-p template-file)
        (copy-file template-file daily-file)))
    (find-file daily-file)))

;; ============================================================================
;; GIT AUTO-SYNC (commit + push on idle, pull on focus/startup)
;; ============================================================================

(defvar my/org-sync-repo-dir org-directory)
(defvar my/org-sync-timer nil)
(defvar my/org-sync-idle-delay 30)

(defun my/org-sync--in-repo-p (file)
  (and file
       (string-prefix-p (expand-file-name my/org-sync-repo-dir)
                         (expand-file-name file))))

(defun my/org-sync-commit-and-push ()
  "Commit any changes in the notes repo and push to GitHub."
  (let ((default-directory my/org-sync-repo-dir))
    (unless (zerop (call-process "git" nil nil nil "diff" "--quiet" "--exit-code"))
      (call-process "git" nil "*org-sync*" nil "add" "-A")
      (call-process "git" nil "*org-sync*" nil "commit" "-m"
                    (format-time-string "auto: %Y-%m-%d %H:%M:%S")))
    (make-process
     :name "org-sync-push"
     :command '("git" "pull" "--rebase" "--autostash")
     :buffer "*org-sync*"
     :sentinel
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (if (zerop (process-exit-status proc))
             (call-process "git" nil "*org-sync*" nil "push")
           (message "org-sync: pull/rebase failed — check *org-sync* buffer")))))))

(defun my/org-sync-schedule ()
  "Reset the idle timer whenever a file inside the notes repo is saved."
  (when (my/org-sync--in-repo-p buffer-file-name)
    (when my/org-sync-timer (cancel-timer my/org-sync-timer))
    (setq my/org-sync-timer
          (run-with-idle-timer my/org-sync-idle-delay nil
                                #'my/org-sync-commit-and-push))))

(add-hook 'after-save-hook #'my/org-sync-schedule)

(defun my/org-sync-pull ()
  "Pull latest notes from GitHub."
  (let ((default-directory my/org-sync-repo-dir))
    (call-process "git" nil 0 nil "pull" "--rebase" "--autostash")))

(add-hook 'focus-in-hook #'my/org-sync-pull)

(add-hook 'emacs-startup-hook
          (lambda ()
            (my/org-sync-pull)
            (my/create-daily-note)))

;; ============================================================================
;; KEYBINDINGS
;; ============================================================================

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find note" "f" #'org-roam-node-find
       :desc "Insert link" "i" #'org-roam-node-insert
       :desc "Toggle backlinks" "l" #'org-roam-buffer-toggle
       :desc "Daily note" "d" #'my/create-daily-note)

      (:prefix ("o" . "org")
       :desc "Capture" "c" #'org-capture
       :desc "Refile" "r" #'org-refile
       :desc "My TODOs" "t" (lambda () (interactive) (org-agenda nil "t"))
       :desc "Habit heatmap" "h" (lambda () (interactive) (org-agenda nil "h"))))

(map! :g "C-c c" #'org-capture)

(map! :map general-override-mode-map
      "M-l" #'evil-window-right
      "M-h" #'evil-window-left
      "M-k" #'evil-window-up
      "M-j" #'evil-window-down)

;; Evil-mode
(setq evil-escape-key-sequence "kj"
      evil-escape-delay 0.1
      evil-move-cursor-back nil
      evil-want-fine-undo t)

;; Auto-save & macOS
(setq auto-save-default t
      delete-by-moving-to-trash t)

(when (eq system-type 'darwin)
  (setq x-no-window-manager t
        frame-inhibit-implied-resize t
        focus-follows-mouse nil))
