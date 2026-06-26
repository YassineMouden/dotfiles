
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

;; Transparency
(when (display-graphic-p)
  (set-frame-parameter (selected-frame) 'alpha '(75. 75))
  (add-to-list 'default-frame-alist '(alpha . (70. 70))))

;; ============================================================================
;; CORE PATHS - ULTIMATE STRUCTURE
;; ============================================================================

(setq org-directory "~/notes/")

;; Define all directories
(defvar soul-dir (concat org-directory "soul/"))
(defvar mind-dir (concat org-directory "mind/"))
(defvar roam-dir (concat org-directory "roam/"))
(defvar daily-dir (concat org-directory "daily/"))
(defvar weekly-dir (concat org-directory "weekly/"))

;; Auto-create directories
(dolist (dir (list soul-dir mind-dir roam-dir daily-dir weekly-dir
                   (concat mind-dir "university/")
                   (concat mind-dir "learning/")
                   (concat mind-dir "coding/")
                   (concat mind-dir "projects/")
                   (concat roam-dir "main/")
                   (concat roam-dir "code/")
                   (concat roam-dir "reference/")
                   (concat org-directory "images/")
                   (concat org-directory "archive/")))
  (unless (file-exists-p dir)
    (make-directory dir t)))

;; ============================================================================
;; ORG-MODE: BASE CONFIGURATION
;; ============================================================================

(after! org
  ;; Agenda files - track everything
  (setq org-agenda-files
        (append (list org-directory
                      (concat org-directory "habits.org")
                      soul-dir
                      mind-dir)
                (directory-files daily-dir t "\\.org$" nil)
                (directory-files weekly-dir t "\\.org$" nil)))

  ;; Display settings
  (setq org-startup-indented t
        org-pretty-entities t
        org-hide-emphasis-markers t
        org-startup-with-inline-images t
        org-image-actual-width '(500)
        org-startup-folded 'content
        org-ellipsis " ▾"
        org-log-done 'time
        org-log-into-drawer t
        org-log-repeat 'time)  ;; Log habit completions

  ;; Line wrapping
  (global-visual-line-mode t)

 ;; ========================================================================
;; HABIT TRACKING - FULL GRAPH VIEW
;; ========================================================================

;; Enable org-habit module
(require 'org-habit)
(add-to-list 'org-modules 'org-habit)

;; CRITICAL SETTINGS FOR GRAPH DISPLAY
(setq org-habit-show-habits t                    ; Always show habits
      org-habit-show-habits-only-for-today nil   ; Show on ALL days, not just today
      org-habit-show-all-today t                 ; Show all habits today
      org-habit-show-done-always-green t         ; Done = green regardless of timing
      org-habit-graph-column 50                  ; Column where graph appears (right side)
      org-habit-preceding-days 21                ; Show 21 days BEFORE today
      org-habit-following-days 7)                ; Show 7 days AFTER today

  ;; ========================================================================
  ;; TODO KEYWORDS
  ;; ========================================================================

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" "WAITING(w)" "|" "DONE(d!)" "CANCELLED(c)")
          (sequence "HABIT(h)" "|" "DONE(d!)")  ;; For habit items
          (sequence "IDEA(i)" "|" "PUBLISHED(p)")
          (sequence "LEARN(l)" "PRACTICE(P)" "|" "MASTERED(m)")))

  (setq org-todo-keyword-faces
        '(("TODO" . (:foreground "#fb4934" :weight bold))
          ("NEXT" . (:foreground "#fabd2f" :weight bold))
          ("ACTIVE" . (:foreground "#b8bb26" :weight bold))
          ("HABIT" . (:foreground "#83a598" :weight bold))
          ("DONE" . (:foreground "#689d6a" :weight bold))))

  
;; ========================================================================
;; CAPTURE TEMPLATES - ULTIMATE EDITION
;; ========================================================================

(setq org-capture-templates
      '(
        ;; === QUICK CAPTURE ===
        ("i" "Inbox" entry
         (file "~/notes/inbox.org")
         "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
         :empty-lines 1)

        ;; === TASKS ===
        ("t" "Task" entry
         (file+headline "~/notes/tasks.org" "Inbox")
         "* TODO %?\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
         :empty-lines 1)

        ;; === DAILY NOTE ===
        ("d" "Daily Note" entry
         (file (lambda () (concat daily-dir (format-time-string "%Y-%m-%d.org"))))
         (file "~/notes/.templates/daily-template.org")
         :empty-lines 0
         :immediate-finish t
         :jump-to-captured t)

        ;; === BRAIN DUMP ===
        ("b" "Brain Dump" entry
         (file+headline
          (lambda () (concat daily-dir (format-time-string "%Y-%m-%d.org")))
          "Brain Dump")
         "* %?\nCaptured: %U\n"
         :empty-lines 1)

        ;; === HABIT ===
        ("h" "Habit" entry
         (file+headline "~/notes/habits.org" "Habits")
         "* HABIT %?\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: HABIT\n:END:\n"
         :empty-lines 1)

        ;; === SOUL ===
        ("s" "Soul")
        
        ("sr" "Random Thought" entry
         (file+headline (concat soul-dir "reflections.org") "Thoughts")
         "* %U - %?\n"
         :empty-lines 1)

        ;; === MIND ===
        ("m" "Mind")
        
        ("mu" "University Note" plain
         (file (lambda ()
                 (let ((course (read-string "Course code: ")))
                   (expand-file-name (concat mind-dir "university/" course ".org")))))
         "#+title: %^{Course Name}\n#+filetags: :university:\n#+date: %U\n\n%?\n"
         :empty-lines 1)

        ("mc" "Code Snippet" entry
         (file+headline (concat mind-dir "coding/snippets.org") "Snippets")
         "* %^{Language} - %^{Description}\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n#+begin_src %\\1\n%?\n#+end_src\n"
         :empty-lines 1)

        ("mi" "Idea" entry
         (file+headline (concat mind-dir "ideas.org") "Ideas")
         "* IDEA %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n%?\n"
         :empty-lines 1)

        ;; === UNIVERSITY COURSE (NOW INSIDE THE LIST!) ===
        ("u" "University")

        ("uc" "Create New Course" plain
         (file (lambda ()
                 (let* ((code (read-string "Course code (e.g., CS101): "))
                        (name (read-string "Course name: "))
                        (semester (read-string "Semester (e.g., Fall2026): "))
                        (professor (read-string "Professor: "))
                        (filename (concat mind-dir "university/" code ".org")))
                   (with-temp-file filename
                     (insert-file-contents "~/.doom.d/templates/course-template.org")
                     (goto-char (point-min))
                     (while (search-forward "${COURSE_CODE}" nil t)
                       (replace-match code))
                     (goto-char (point-min))
                     (while (search-forward "${COURSE_NAME}" nil t)
                       (replace-match name))
                     (goto-char (point-min))
                     (while (search-forward "${SEMESTER}" nil t)
                       (replace-match semester))
                     (goto-char (point-min))
                     (while (search-forward "${PROFESSOR}" nil t)
                       (replace-match professor)))
                   filename)))
         ""
         :immediate-finish t
         :jump-to-captured t)

        ("uh" "Homework/Assignment" entry
         (file+headline
          (lambda ()
            (let ((course (completing-read "Course: "
                                            (directory-files (concat mind-dir "university/")
                                                             nil "\\.org$"))))
              (concat mind-dir "university/" course)))
          "Homework & Assignments")
         "** TODO %^{Assignment Name}\nDEADLINE: %^{Due date}t\nSCHEDULED: %^{Start date}t\n:PROPERTIES:\n:POINTS: %^{Points}\n:STATUS: Not Started\n:END:\n\n*** Description\n%?\n\n*** Requirements\n- [ ] \n\n*** Notes\n"
         :empty-lines 1)

        ("un" "Lecture Note" entry
         (file+headline
          (lambda ()
            (let ((course (completing-read "Course: "
                                            (directory-files (concat mind-dir "university/")
                                                             nil "\\.org$"))))
              (concat mind-dir "university/" course)))
          "Lecture Notes")
         "** Lecture %^{Number} - %^{Title}\n<%<%Y-%m-%d %a>>\n\n*** Main Points\n- %?\n\n*** Key Concepts\n- \n\n*** Questions\n- [ ] \n"
         :empty-lines 1)))  ;; <-- IMPORTANT: This closes the entire list!
  ;; ========================================================================
  ;; REFILE
  ;; ========================================================================

  (setq org-refile-targets
        '((("~/notes/tasks.org") :maxlevel . 3)
          (("~/notes/habits.org") :maxlevel . 2)
          ((concat soul-dir "reflections.org") :maxlevel . 2)
          ((concat mind-dir "ideas.org") :maxlevel . 2)
          (org-agenda-files :maxlevel . 3)))

  (setq org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm)


;; ========================================================================
;; AGENDA - ULTIMATE DASHBOARD
;; ========================================================================

(setq org-agenda-span 'day
      org-agenda-start-on-weekday nil
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-time-grid
      '((daily today require-timed)
        (800 1000 1200 1400 1600 1800 2000)
        "......" "----------------"))

;; Make sure habits show in agenda
(setq org-habit-show-habits t
      org-habit-show-habits-only-for-today nil)

;; Custom agenda views
(setq org-agenda-custom-commands
      '(("d" "📅 Daily Dashboard"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-overriding-header "\n📅 Today's Schedule\n")))
          (todo "HABIT"
                ((org-agenda-overriding-header "\n✅ Daily Habits\n")
                 (org-agenda-skip-function '(org-agenda-skip-entry-if 'done))))
          (tags-todo "+PRIORITY=\"A\""
                     ((org-agenda-overriding-header "\n🔥 High Priority\n")))
          (tags-todo "+CATEGORY=\"work\""
                     ((org-agenda-overriding-header "\n💼 Work\n")))
          (tags-todo "+CATEGORY=\"learning\""
                     ((org-agenda-overriding-header "\n📚 Learning\n")))))

        ("w" "📊 Weekly Review"
         ((tags "WEEKLY_REVIEW"
                ((org-agenda-overriding-header "\n📊 Weekly Review Checklist\n")))
          (todo "NEXT"
                ((org-agenda-overriding-header "\n⏭️  Next Actions\n")))
          (todo "WAITING"
                ((org-agenda-overriding-header "\n⏸️  Waiting For\n")))
          (tags-todo "+project"
                     ((org-agenda-overriding-header "\n🚀 Active Projects\n")))
          (todo "HABIT"
                ((org-agenda-overriding-header "\n📈 Habit Completion This Week\n")))))

        
        
("h" "🏠 Habit Tracker"
 ((agenda "" 
          ((org-agenda-span 'week)
           (org-agenda-overriding-header "\n📊 Week View with Habits\n")
           (org-agenda-start-on-weekday 0)))
  (todo "HABIT"
        ((org-agenda-overriding-header "\n📈 Habit Consistency Graphs\n")
         (org-agenda-format-date "")
         (org-agenda-remove-times-when-in-prefix t)))))
        
        ("n" "📝 Next Actions" 
         todo "NEXT"
         ((org-agenda-overriding-header "\n⏭️  Next Actions\n")))

        ("u" "📚 University Dashboard"
         ((tags-todo "+university+PRIORITY=\"A\""
                     ((org-agenda-overriding-header "\n🔥 High Priority University Tasks\n")))
          (agenda "" ((org-agenda-span 14)
                      (org-agenda-overriding-header "\n📅 Next 2 Weeks\n")))
          (tags-todo "+university+TODO=\"TODO\""
                     ((org-agenda-overriding-header "\n📝 All University TODOs\n")))
          (tags "+university+DEADLINE>=\"<today>\"+DEADLINE<=\"<+30d>\""
                ((org-agenda-overriding-header "\n⚠️  Upcoming Deadlines (30 days)\n")))))

        ("D" "🚨 Deadlines Only"
         ((tags "+DEADLINE>=\"<today>\"+DEADLINE<=\"<+7d>\""
                ((org-agenda-overriding-header "\n📌 This Week's Deadlines\n")))
          (tags "+DEADLINE>=\"<+8d>\"+DEADLINE<=\"<+30d>\""
                ((org-agenda-overriding-header "\n🔜 Next 3 Weeks\n")))
          (tags "+DEADLINE<\"<today>\""
                ((org-agenda-overriding-header "\n⚠️  OVERDUE\n")))))))

;; Archive
(setq org-archive-location (concat org-directory "archive/%s_archive::")))
;; ============================================================================
;; ORG-ROAM: Your Second Brain
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
           :unnarrowed t)

          ("l" "learning" plain "%?"
           :target (file+head "main/${slug}.org"
                              "#+title: ${title}\n#+filetags: :learning:\n#+date: %U\n\n* Key Concepts\n\n%?\n\n* Connections\n")
           :unnarrowed t)

          ("c" "code" plain "%?"
           :target (file+head "code/${slug}.org"
                              "#+title: ${title}\n#+filetags: :code:\n#+date: %U\n\n%?")
           :unnarrowed t)

          ("r" "reference" plain "%?"
           :target (file+head "reference/${slug}.org"
                              "#+title: ${title}\n#+filetags: :reference:\n#+date: %U\n\n%?")
           :unnarrowed t))))

;; Org-roam UI
(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

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

(defun my/create-weekly-review ()
  "Create or open this week's review."
  (interactive)
  (let* ((week-file (concat weekly-dir (format-time-string "%Y-W%W.org")))
         (template-file "~/.doom.d/templates/weekly-template.org"))
    (unless (file-exists-p week-file)
      (when (file-exists-p template-file)
        (copy-file template-file week-file)))
    (find-file week-file)))

;; Auto-open daily note on Emacs startup [web:128]
(add-hook 'emacs-startup-hook #'my/create-daily-note)

;; ============================================================================
;; KEYBINDINGS
;; ============================================================================

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find note" "f" #'org-roam-node-find
       :desc "Insert link" "i" #'org-roam-node-insert
       :desc "Toggle backlinks" "l" #'org-roam-buffer-toggle
       :desc "Roam UI" "u" #'org-roam-ui-mode
       :desc "Daily note" "d" #'my/create-daily-note
       :desc "Weekly review" "w" #'my/create-weekly-review)

      (:prefix ("o" . "org")
       :desc "Capture" "c" #'org-capture
       :desc "Agenda" "a" #'org-agenda
       :desc "Refile" "r" #'org-refile
       :desc "Pomodoro" "p" #'org-pomodoro
       :desc "Calendar" "C" #'my/open-calendar         ;; NEW!
       :desc "Schedule" "s" #'org-schedule             ;; NEW!
       :desc "Deadline" "d" #'org-deadline))           ;; NEW!

;; Quick capture
(map! :g "C-c c" #'org-capture)

;; Window navigation
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


;; ============================================================================
;; CALENDAR VIEW (Visual Schedule)
;; ============================================================================

(use-package! calfw)
(use-package! calfw-org)

;; Calendar function [web:141]
(defun my/open-calendar ()
  "Open calendar in a workspace showing org agenda items."
  (interactive)
  (if (featurep! :ui workspaces)
      (progn
        (+workspace-switch "Calendar" t)
        (cfw:open-org-calendar))
    (cfw:open-org-calendar)))

;; Calendar settings
(after! calfw
  (setq cfw:fchar-junction ?╋
        cfw:fchar-vertical-line ?┃
        cfw:fchar-horizontal-line ?━
        cfw:fchar-left-junction ?┣
        cfw:fchar-right-junction ?┫
        cfw:fchar-top-junction ?┳
        cfw:fchar-top-left-corner ?┏
        cfw:fchar-top-right-corner ?┓)
  
  ;; Week starts on Monday
  (setq calendar-week-start-day 1))

;; ============================================================================
;; DEADLINES & SCHEDULING [web:135][web:136]
;; ============================================================================

(after! org
  ;; Deadline warning days (shows "In X days" warnings)
  (setq org-deadline-warning-days 7)  ;; Warn 7 days before deadline
  
  ;; Show deadlines in agenda even if scheduled
  (setq org-agenda-skip-deadline-prewarning-if-scheduled nil)
  
  ;; Upcoming deadlines
  (setq org-agenda-deadline-faces
        '((1.0 . org-warning)              ;; Due today - red
          (0.5 . org-upcoming-deadline)    ;; 50% of warning time
          (0.0 . org-upcoming-distant-deadline))))  ;; Just appeared

