
;;
;;
;; Org-mode settings
;;
;;
;;
;;
(provide 'orgsettings)
(require 'org-install)
;(require 'org-checklist)


(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(setq org-log-done t)
(setq org-agenda-files (list "~/.org/work.org"
			     "~/.org/college.org"
			     "~/.org/personal.org"
			     "~/.org/hobbies.org"
;			     "~/.org/notes.org"
))

(setq org-todo-keywords 
  (quote
    ((sequence 
      "TODO(t!)" "STARTED(z!)" "NEXT(n!)" "|" "DONE(d!/!)")
     (sequence 
      "WAITING(w@/!)" "SOMEDAY(s!)" "|" "CANCELLED(c@/!)") 
     (sequence 
      "QUOTE(q!)" "QUOTED(Q!)" "|" 
      "APPROVED(A@)" "EXPIRED(E@)" "REJECTED(R@)")
     (sequence "OPEN(O!)" "|" "CLOSED(C!)"))))
(setq org-use-fast-todo-selection t)
(setq org-todo-keyword-faces
      (quote (("TODO"      :foreground "red"          :weight bold)
              ("STARTED"   :foreground "orange"       :weight bold)
    	      ("NEXT"      :foreground "blue"         :weight bold)
              ("DONE"      :foreground "forest green" :weight bold)
              ("WAITING"   :foreground "yellow"       :weight bold)
              ("SOMEDAY"   :foreground "goldenrod"    :weight bold)
              ("CANCELLED" :foreground "orangered"    :weight bold)
              ("QUOTE"     :foreground "hotpink"      :weight bold)
              ("QUOTED"    :foreground "indianred1"   :weight bold)
              ("APPROVED"  :foreground "forest green" :weight bold)
              ("EXPIRED"   :foreground "olivedrab1"   :weight bold)
              ("REJECTED"  :foreground "olivedrab"    :weight bold)
              ("OPEN"      :foreground "magenta"      :weight bold)
              ("CLOSED"    :foreground "forest green" :weight bold))))
;;
;; Tags
;;

(setq org-tag-alist
(quote
 ((:startgroup)
  ("@personal" . ?0)
  ("@college" . ?1)
  ("@office" . ?2)
  ("@social" . ?3)
  ("@research". ?4)
  (:endgroup)
  ("PHONE" . ?p)
  ("IMPORTANT". ?i)
  ("URGENT" . ?u)
  ("HABIT" . ?h)
  ("NOTE" . ?n)
  )))
(setq org-tag-faces
'(("@personal" :foreground "green")
  ("@college" :foreground "blue")
  ("@office" :foreground "magenta")
  ("@social" :foreground "yellow")
  ("@research" :foreground "dark khaki")
  ("IMPORTANT" :foreground "red" :weight bold)
  )
)

;; Custom Key Bindings
(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key (kbd "<f5>") 'bh/org-todo)
(global-set-key (kbd "<S-f5>") 'bh/widen)
(global-set-key (kbd "<f7>") 'set-truncate-lines)
(global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
(global-set-key (kbd "<f9> b") 'bbdb)
(global-set-key (kbd "<f9> c") 'calendar)
(global-set-key (kbd "<f9> f") 'boxquote-insert-file)
(global-set-key (kbd "<f9> g") 'gnus)
(global-set-key (kbd "<f9> h") 'bh/hide-other)

(defun bh/org-todo ()
  (interactive)
  (widen)
  (org-narrow-to-subtree)
  (org-show-todo-tree nil))

(defun bh/widen ()
  (interactive)
  (widen)
  (org-reveal))

(defun bh/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (org-shifttab)
    (org-reveal)
    (org-cycle)))

(global-set-key (kbd "<f9> i") 'bh/org-info)

(defun bh/org-info ()
  (interactive)
  (info "~/git/org-mode/doc/org.info"))

(global-set-key (kbd "<f9> I") 'bh/punch-in)
(global-set-key (kbd "<f9> O") 'bh/punch-out)
(global-set-key (kbd "<f9> r") 'boxquote-region)
(global-set-key (kbd "<f9> s") 'bh/switch-to-org-scratch)


;; Clock settings

;;
;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)
;;
;; Small windows on my Eee PC displays only the end of long lists which isn't very useful
(setq org-clock-history-length 10)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task to STARTED when clocking in
(setq org-clock-in-switch-to-state 'bh/clock-in-to-started)
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))
;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist (quote history))
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)

(setq bh/keep-clock-running nil)

(defun bh/clock-in-to-started (kw)
  "Switch task from TODO or NEXT to STARTED when clocking in.
Skips capture tasks."
  (if (and (member (org-get-todo-state) (list "TODO" "NEXT"))
           (not (and (boundp 'org-capture-mode) org-capture-mode)))
      "STARTED"))

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (let ((parent-task (save-excursion (org-back-to-heading) (point))))
    (while (org-up-heading-safe)
      (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
        (setq parent-task (point))))
    (goto-char parent-task)
    parent-task))

(defun bh/clock-in-and-set-project-as-default (pom)
  "Clock in the current task and set the parent project (if any) as the
default clocking task.  Agenda filter tags are set from the default task"
  ;; Find the parent project task if any and set that as the default
  (save-excursion
    (save-excursion
      (org-with-point-at pom
        (bh/find-project-task)
        (org-clock-in '(16))))
    (save-excursion
      (org-with-point-at pom
        (org-clock-in nil)))))

(defun bh/set-agenda-restriction-lock ()
  "Set filter to tags of POM, current task, or current project and refresh"
  (interactive)
  ;;
  ;; We're in the agenda
  ;;
  (let* ((pom (org-get-at-bol 'org-hd-marker))
         (tags (org-with-point-at pom (org-get-tags-at))))
    (if (equal major-mode 'org-agenda-mode)
        (if tags
            (org-with-point-at pom
              (bh/find-project-task)
              (org-agenda-set-restriction-lock))
          (org-agenda-remove-restriction-lock))
      (if (equal org-clock-default-task (org-id-find "eb155a82-92b2-4f25-a3c6-0304591af2f9" 'marker))
          (org-agenda-remove-restriction-lock)
        (org-with-point-at pom
          (bh/find-project-task)
          (org-agenda-set-restriction-lock))))))

(defun bh/punch-in ()
  "Start continuous clocking and set the default task to the project task
of the selected task.  If no task is selected set the Organization task as
the default task."
  (interactive)
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if tags
            (bh/clock-in-and-set-project-as-default marker)
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
      ; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)))
          (bh/clock-in-and-set-project-as-default nil)
        (bh/clock-in-organization-task-as-default))))
  (bh/set-agenda-restriction-lock))

(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (save-restriction
    (widen)
    (org-with-point-at (org-id-find "eb155a82-92b2-4f25-a3c6-0304591af2f9" 'marker)
      (org-clock-in '(16)))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-default-task)))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(defun bh/switch-to-org-scratch ()
  "Switch to a temp Org buffer.
If the region is active, insert it."
  (interactive)
  (let ((contents
         (and (region-active-p)
              (buffer-substring (region-beginning)
                                (region-end)))))
    (find-file "/tmp/org-scratch.org")
    (if contents (insert contents))))

(global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
(global-set-key (kbd "<f9> u") 'bh/untabify)

(defun bh/untabify ()
  (interactive)
  (untabify (point-min) (point-max)))

(global-set-key (kbd "<f9> v") 'visible-mode)
(global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
(global-set-key (kbd "C-<f9>") 'previous-buffer)
(global-set-key (kbd "C-x r") 'narrow-to-region)
(global-set-key (kbd "C-<f10>") 'next-buffer)
(global-set-key (kbd "<f11>") 'org-clock-goto)
(global-set-key (kbd "C-<f11>") 'org-clock-in)
(global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)
(global-set-key (kbd "M-<f11>") 'org-resolve-clocks)
(global-set-key (kbd "C-M-r") 'org-capture)
(global-set-key (kbd "M-<f9>") (lambda ()
                                 (interactive)
                                 (unless (buffer-modified-p)
                                   (kill-buffer (current-buffer)))
                                 (delete-frame)))

(setq org-use-fast-todo-selection t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

;;
;; Agenda tweaks
;;


(setq org-agenda-show-all-dates t)
(setq org-agenda-sorting-strategy
      (quote ((agenda habit-down time-up user-defined-up priority-down effort-up category-keep)
              (todo priority-down)
              (tags priority-down))))
(setq org-agenda-time-grid
      (quote (nil "----------------"
                  (800 1000 1200 1400 1600 1800 2000))))

(setq org-agenda-tags-column 075)


;; Match tags and show content
(defun org-tag-match-context (&optional todo-only match)
  "Identical search to `org-match-sparse-tree', but shows the content of the matches."
  (interactive "P")
  (org-prepare-agenda-buffers (list (current-buffer)))
  (org-overview) 
  (org-remove-occur-highlights) 
  (org-scan-tags '(progn (org-show-entry) 
                         (org-show-context)) 
                 (cdr (org-make-tags-matcher match)) todo-only))
(global-set-key (kbd "<f9> m") 'org-tag-match-context)

;; Latex export settings
(require 'org-latex)
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(setq org-export-latex-packages-alist
      '(("AUTO" "inputenc" t)
	("T1" "fontenc" t)
	("" "hyperref" nil)
	
"\\tolerance=1000
\\setlength{\\textheight}{9in}
\\setlength{\\textwidth}{6.5in}
\\setlength{\\evensidemargin}{0in}
\\setlength{\\oddsidemargin}{0in}
\\setlength{\\topmargin}{0in}
\\setlength{\\headheight}{0in}
"))
(add-to-list 'org-export-latex-classes
	     '("article"
	       "\\documentclass{article}
[NO-DEFAULT-PACKAGES]
[PACKAGES]
[EXTRA]"
  ("\\section{%s}" . "\\section*{%s}")
  ("\\subsection{%s}" . "\\subsection*{%s}")
  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; References
(defun org-mode-reftex-setup ()
  (interactive)
  (and (buffer-file-name) (file-exists-p (buffer-file-name))
       (progn
        ; Reftex should use the org file as master file. See C-h v TeX-master for infos.
        (setq TeX-master t)
        (turn-on-reftex)
        ; dont ask for the tex master on every start.
	(setq reftex-default-bibliography
	      (quote
	       ("~/default.bib")))
        (reftex-parse-all)
        ;add a custom reftex cite format to insert links
        (reftex-set-cite-format
         '((?b . "[[bib:%l][%l-bib]]")
           (?n . "[[notes:%l][%l-notes]]")
           (?p . "[[papers:%l][%l-paper]]")
           (?t . "%t")
           (?h . "** %t\n:PROPERTIES:\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-paper]]")))))
  (define-key org-mode-map (kbd "C-c )") 'reftex-citation)
  (define-key org-mode-map (kbd "C-c (") 'org-mode-reftex-search))

(add-hook 'org-mode-hook 'org-mode-reftex-setup)

;; Custom export blocks
(setq org-export-blocks
  (cons '(latexmacro org-export-blocks-latexmacro) org-export-blocks))

(defun org-export-blocks-latexmacro (body &rest headers)
  (message "exporting latex macros")
  (cond
   ((eq org-export-current-backend 'html) (concat "\\(" body "\\)"))
   ((eq org-export-current-backend 'latex) (concat "#+BEGIN_LATEX\n" body "#+END_LATEX\n"))
   (t nil))
)

(setq org-export-publishing-directory "./exports")
(print org-export-publishing-directory)

