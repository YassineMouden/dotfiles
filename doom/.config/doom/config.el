;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ============================================================================
;; IDENTITY & APPEARANCE
;; ============================================================================

(setq user-full-name "Yacin"
      user-mail-address "jasinpr9915@gmail.com")

(setq doom-font (font-spec :family "Fira Code" :size 15)
      doom-variable-pitch-font (font-spec :family "JuliaMono" :size 18)
      doom-symbol-font (font-spec :family "JuliaMono")
      doom-big-font (font-spec :family "JuliaMono" :size 22))

(setq doom-theme 'doom-gruvbox)
(setq display-line-numbers-type 'relative)

(when (display-graphic-p)
  (set-frame-parameter (selected-frame) 'alpha '(75. 75))
  (add-to-list 'default-frame-alist '(alpha . (70. 70))))

;; ============================================================================
;; CORE PATHS — "The Workshop"
;; ============================================================================
;; Capture -> Learn -> Build -> Write -> Publish.
;; See ~/.config/doom/README.md for the full philosophy this mirrors.

(setq org-directory "~/life/")

(defvar inbox-dir      (concat org-directory "inbox/"))
(defvar today-dir      (concat org-directory "today/"))
(defvar projects-dir   (concat org-directory "projects/"))
(defvar knowledge-dir  (concat org-directory "knowledge/"))
(defvar writing-dir    (concat org-directory "writing/"))
(defvar drafts-dir     (concat writing-dir "drafts/"))
(defvar journal-dir    (concat writing-dir "journal/"))
(defvar library-dir    (concat org-directory "library/"))
(defvar books-dir      (concat library-dir "books/"))
(defvar articles-dir   (concat library-dir "articles/"))
(defvar templates-dir  (concat org-directory "templates/"))
(defvar archive-dir    (concat org-directory "archive/"))

(defvar inbox-file     (concat inbox-dir "inbox.org"))
(defvar tasks-file     (concat org-directory "tasks.org"))
(defvar habits-file    (concat org-directory "habits.org"))
(defvar reading-file   (concat org-directory "reading.org"))
(defvar wishlist-file  (concat org-directory "wishlist.org"))
(defvar bookmarks-file (concat library-dir "bookmarks.org"))

;; ============================================================================
;; TEMPLATE HELPERS
;; ============================================================================
;; Small hand-rolled %%KEY%% renderer instead of leaning on org-capture's
;; escape engine, since these files (today's note, new drafts, new knowledge
;; notes...) are often created outside of an actual capture flow. Deliberately
;; plain string substitution — no magic, easy to read top to bottom.

(defun my/--slugify (s)
  "Turn S into a lowercase, hyphenated, filename-safe slug."
  (let ((slug (downcase s)))
    (setq slug (replace-regexp-in-string "[^a-z0-9]+" "-" slug))
    (setq slug (replace-regexp-in-string "\\`-+\\|-+\\'" "" slug))
    slug))

(defun my/--subdirs (dir)
  "Return the names (not full paths) of DIR's immediate subdirectories."
  (when (file-directory-p dir)
    (mapcar #'file-name-nondirectory
            (seq-filter #'file-directory-p
                        (directory-files dir t "\\`[^.]")))))

(defun my/--render-template (template-file replacements)
  "Return TEMPLATE-FILE's contents with %%KEY%% swapped per REPLACEMENTS alist."
  (with-temp-buffer
    (insert-file-contents template-file)
    (dolist (pair replacements)
      (goto-char (point-min))
      (while (search-forward (format "%%%%%s%%%%" (car pair)) nil t)
        (replace-match (cdr pair) t t)))
    (buffer-string)))

(defun my/--new-file-from-template (template-file target-file replacements)
  "Create TARGET-FILE from TEMPLATE-FILE (if it doesn't already exist), then visit it."
  (make-directory (file-name-directory target-file) t)
  (unless (file-exists-p target-file)
    (with-temp-file target-file
      (insert (my/--render-template template-file replacements))))
  (find-file target-file))

(defun my/--ensure-file (file title)
  "Create FILE with a bare #+title: TITLE header if it doesn't already exist."
  (unless (file-exists-p file)
    (make-directory (file-name-directory file) t)
    (with-temp-file file
      (insert (format "#+title: %s\n\n" title)))))

;; ============================================================================
;; SCAFFOLD THE WORKSHOP ON FIRST RUN
;; ============================================================================

(dolist (dir (list inbox-dir today-dir projects-dir knowledge-dir
                   writing-dir drafts-dir journal-dir
                   library-dir books-dir articles-dir
                   templates-dir archive-dir))
  (unless (file-exists-p dir)
    (make-directory dir t)))

;; Starter subfolders — matches the layout already in use (website, homelab,
;; dotfiles homelab work; linux/emacs/networking/programming coursework).
;; Add more with `SPC n p n' / `SPC n k n' as they come up.
(dolist (proj '("website" "homelab" "dotfiles" "university" "thinkpad"))
  (make-directory (concat projects-dir proj "/") t))

(dolist (topic '("linux" "emacs" "networking" "programming" "philosophy"))
  (make-directory (concat knowledge-dir topic "/") t))

(my/--ensure-file inbox-file "Inbox")
(my/--ensure-file tasks-file "Tasks")
(my/--ensure-file habits-file "Habits")
(my/--ensure-file reading-file "Reading")
(my/--ensure-file wishlist-file "Wishlist")
(my/--ensure-file bookmarks-file "Bookmarks")

;; ============================================================================
;; ORG-MODE: BASE CONFIGURATION
;; ============================================================================

(after! org
  ;; Agenda pulls from the two permanent lists plus every daily note.
  ;; Project-scoped todo.org files stay out of the agenda on purpose — they're
  ;; backlog/planning, not necessarily dated. They're still reachable via
  ;; refile (see below) and `SPC n p p'.
  (setq org-agenda-files
        (append (list tasks-file habits-file)
                (directory-files today-dir t "\\.org$" nil)))

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
        org-habit-show-habits-only-for-today t
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
        `(("i" "Inbox" entry
           (file ,inbox-file)
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("t" "Task" entry
           (file+headline ,tasks-file "Inbox")
           "* TODO %?\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ("h" "Habit" entry
           (file+headline habits-file "Habits")
           "* HABIT %?\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: HABIT\n:END:\n"
           :empty-lines 1)

          ("j" "Journal" entry
           (file+olp+datetree (lambda () (concat journal-dir (format-time-string "%Y.org"))))
           "* %?\n%U\n"
           :empty-lines 1)))

  ;; --- Refile ---
  (defun my/project-todo-files ()
    "Return every existing projects/*/todo.org path."
    (when (file-directory-p projects-dir)
      (delq nil
            (mapcar (lambda (dir)
                      (let ((f (expand-file-name "todo.org" dir)))
                        (when (file-exists-p f) f)))
                    (seq-filter #'file-directory-p
                                (directory-files projects-dir t "\\`[^.]"))))))

  (setq org-refile-targets
        '((tasks-file :maxlevel . 2)
          (habits-file :maxlevel . 1)
          (my/project-todo-files :maxlevel . 2)))

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
                     (org-agenda-overriding-header "\nHabit Heatmap\n")
                     ))))))

  (setq org-archive-location (concat archive-dir "%s_archive::")))

;; ============================================================================
;; ORG-ROAM  (backs knowledge/)
;; ============================================================================

(use-package! org-roam
  :after org
  :init
  (setq org-roam-directory (file-truename knowledge-dir))
  :config
  (org-roam-db-autosync-mode)

  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:30}" 'face 'org-tag)))

  ;; Quick capture (SPC n f on a new title) lands a flat node at the root of
  ;; knowledge/. For a note filed under a specific topic folder (knowledge/linux/,
  ;; knowledge/emacs/...), use `SPC n k n' instead — see below.
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n\n* What is it?\n\n* Advantages\n\n* Commands / Usage\n\n* References\n\n")
           :unnarrowed t))))

;; ============================================================================
;; ROAM UI, IMAGE DROP, POMODORO
;; ============================================================================

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

(use-package! org-download
  :after org
  :config
  (setq org-download-method 'directory
        org-download-image-dir (concat org-directory "assets/")
        org-download-heading-lvl nil
        org-download-timestamp "%Y%m%d-%H%M%S-"))

(use-package! org-pomodoro
  :after org
  :config
  (setq org-pomodoro-length 25
        org-pomodoro-short-break-length 5
        org-pomodoro-long-break-length 15))

;; ============================================================================
;; TODAY'S NOTE
;; ============================================================================

(defun my/open-today ()
  "Open (or create) today's note under today/."
  (interactive)
  (my/--new-file-from-template
   (concat templates-dir "today-template.org")
   (concat today-dir (format-time-string "%Y-%m-%d.org"))
   `(("DATE" . ,(format-time-string "%Y-%m-%d"))
     ("WEEKDAY" . ,(format-time-string "%A")))))

;; ============================================================================
;; PROJECTS
;; ============================================================================

(defun my/open-project ()
  "Pick a project under projects/ and open it in Dired."
  (interactive)
  (let* ((names (my/--subdirs projects-dir))
         (choice (completing-read "Project: " names)))
    (dired (expand-file-name choice projects-dir))))

(defun my/new-project (name)
  "Scaffold a new projects/<name>/ with roadmap.org, ideas.org, todo.org, notes.org."
  (interactive "sProject name: ")
  (let* ((slug (my/--slugify name))
         (dir (file-name-as-directory (concat projects-dir slug))))
    (dolist (spec '(("roadmap.org" . "Roadmap")
                    ("ideas.org" . "Ideas")
                    ("todo.org" . "To-do")
                    ("notes.org" . "Notes")))
      (my/--new-file-from-template
       (concat templates-dir "project-file-template.org")
       (concat dir (car spec))
       `(("TITLE" . ,(format "%s — %s" name (cdr spec)))
         ("DATE" . ,(format-time-string "%Y-%m-%d")))))
    (dired dir)))

;; ============================================================================
;; WRITING  (drafts -> ox-hugo -> website)
;; ============================================================================

(defun my/new-draft (title)
  "Create a new writing/drafts/<slug>.org."
  (interactive "sDraft title: ")
  (my/--new-file-from-template
   (concat templates-dir "draft-template.org")
   (concat drafts-dir (my/--slugify title) ".org")
   `(("TITLE" . ,title) ("DATE" . ,(format-time-string "%Y-%m-%d")))))

;; The website itself lives at projects/website/ (a real Hugo repo checkout).
;; `SPC n w p' runs ox-hugo's standard per-file/subtree export; running `hugo`
;; itself (build/deploy) stays a shell/CI concern outside Emacs.
(after! ox-hugo
  (setq org-hugo-base-dir (concat projects-dir "website")))

;; ============================================================================
;; KNOWLEDGE  (knowledge/<topic>/, doubles as org-roam nodes)
;; ============================================================================

(defun my/new-knowledge-note (topic title)
  "Create a new knowledge/<topic>/<slug>.org. Picked up by org-roam automatically."
  (interactive
   (list (completing-read "Topic: " (my/--subdirs knowledge-dir))
         (read-string "Title: ")))
  (my/--new-file-from-template
   (concat templates-dir "knowledge-template.org")
   (concat knowledge-dir (file-name-as-directory topic) (my/--slugify title) ".org")
   `(("TITLE" . ,title) ("DATE" . ,(format-time-string "%Y-%m-%d")))))

;; ============================================================================
;; LIBRARY  (books/, articles/)
;; ============================================================================

(defun my/new-book-note (title)
  "Create a new library/books/<slug>.org."
  (interactive "sBook title: ")
  (my/--new-file-from-template
   (concat templates-dir "library-template.org")
   (concat books-dir (my/--slugify title) ".org")
   `(("TITLE" . ,title) ("DATE" . ,(format-time-string "%Y-%m-%d")))))

(defun my/new-article-note (title)
  "Create a new library/articles/<slug>.org."
  (interactive "sArticle title: ")
  (my/--new-file-from-template
   (concat templates-dir "library-template.org")
   (concat articles-dir (my/--slugify title) ".org")
   `(("TITLE" . ,title) ("DATE" . ,(format-time-string "%Y-%m-%d")))))

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
  "Commit any changes in the notes repo and push to the remote."
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
  "Pull latest notes from the remote."
  (let ((default-directory my/org-sync-repo-dir))
    (call-process "git" nil 0 nil "pull" "--rebase" "--autostash")))

(add-hook 'focus-in-hook #'my/org-sync-pull)

(add-hook 'emacs-startup-hook
          (lambda ()
            (my/org-sync-pull)
            (my/open-today)))

;; ============================================================================
;; KEYBINDINGS
;; ============================================================================

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Open today's note"     "t" #'my/open-today
       :desc "Capture to inbox"      "c" (lambda () (interactive) (org-capture nil "i"))
       :desc "Capture journal entry" "j" (lambda () (interactive) (org-capture nil "j"))
       :desc "Find/create roam node" "f" #'org-roam-node-find
       :desc "Insert roam link"      "i" #'org-roam-node-insert
       :desc "Toggle backlinks"      "l" #'org-roam-buffer-toggle
       :desc "Roam UI graph"         "u" #'org-roam-ui-open

       ;; NOTE: these live under SPC n rather than top-level SPC p / SPC w —
       ;; those are Doom's built-in projectile and window-management prefixes,
       ;; and reusing them here would silently override bindings you already
       ;; rely on (SPC p p = projectile-switch-project, SPC w = window map).
       (:prefix ("p" . "projects")
        :desc "Open a project" "p" #'my/open-project
        :desc "New project"    "n" #'my/new-project)

       (:prefix ("w" . "writing")
        :desc "New draft"         "n" #'my/new-draft
        :desc "Publish (ox-hugo)" "p" #'org-hugo-export-wim-to-md)

       (:prefix ("k" . "knowledge")
        :desc "New knowledge note" "n" #'my/new-knowledge-note)

       (:prefix ("b" . "library")
        :desc "New book note"    "b" #'my/new-book-note
        :desc "New article note" "a" #'my/new-article-note))

      (:prefix ("o" . "org")
       :desc "Capture"       "c" #'org-capture
       :desc "Refile"        "r" #'org-refile
       :desc "My TODOs"      "t" (lambda () (interactive) (org-agenda nil "t"))
       :desc "Habit heatmap" "h" (lambda () (interactive) (org-agenda nil "h"))
       :desc "Pomodoro"      "p" #'org-pomodoro))

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
