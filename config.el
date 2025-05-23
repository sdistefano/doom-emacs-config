;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Silvio Di Stefano"
      user-mail-address "sdistefano@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(if IS-MAC
	(autoload 'ispell-get-word' "ispell")
)

;; (defun lookup-word (word)
;;   (interactive (list (save-excursion (car (ispell-get-word nil)))))
;;   (browse-url (format "http://en.wiktionary.org/wiki/%s" word)))

;; (global-set-key (kbd "M-#") 'lookup-word')
(projectile-add-known-project "~/OneDrive/Writing Group")
(projectile-add-known-project "~/OneDrive/Languages")

;; (def-package! org-super-agenda
;;   :after org-agenda
;;   :init
;;   (setq org-super-agenda-groups '((:name "Today"
;;                                    :time-grid t
;;                                    :scheduled today)
;;                                   (:name "Due Today"
;;                                    :deadline today)
;;                                   (:name "Important"
;;                                    :priority "A")
;;                                   (:name "Overdue"
;;                                    :priority past)
;;                                   (:name "Due soon"
;;                                    :priority future)
;;                                   ))
;;   :config
;;   (org-super-agenda-mode)
;; )
(setq projectile-project-search-path '("~/proj/"))
;; (define-key evil-insert-state-map (kbd "C-c C-c") 'evil-normal-state)
;; (define-key evil-normal-state-map (kbd "C-c C-c") 'evil-normal-state)

(defun shell-command-on-region-to-string (start end command)
  (with-output-to-string
    (shell-command-on-region start end command standard-output))
)

 (defun hiragana-region (&optional b e)
   (setq str (current-kill 0))
   (insert (shell-command-to-string (format "echo %s | kakasi -iutf8 -outf8 -JH -f" str)) )
 )

;; (defun hiragana-region (&optional b e)
;;   (interactive "r")
;;   (kill-new (shell-command-on-region-to-string b e "kakasi -iutf8 -outf8 -JH -f"))
;; )

(defvar *km:kanji->hiragana* "-JHf"
  "Kakasi comman-line options for converting kanji to hiragana.")

(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))


(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)
(setq google-translate-default-source-language "en")
(setq google-translate-default-target-language "de")
(unless IS-MAC
	(setq google-translate-default-target-language "ja")
)


;; (setq google-translate-output-destination 'current-buffer)
(setq google-translate-output-destination 'kill-ring)

(use-package google-translate
:demand t
:init
        (require 'google-translate)

:functions (my-google-translate-at-point google-translate--search-tkk my-google-translate google-translate-at-point2)
:custom
(google-translate-backend-method 'curl)
:config
(defun google-translate--search-tkk () "Search TKK." (list 430675 2721866130))

;; Helper function to handle translation and insertion
(defun translate-and-insert-line ()
  "Translate current line and insert result below"
  (select-current-line)
  (google-translate-at-point)
  (save-excursion
    (end-of-line)
    (open-line 1))
  (forward-line)
  (yank)
  (open-line 1)
  (forward-line 2)
  (evil-org-open-below 1))

;; Main translation function that handles both Japanese and other languages
(defun google-translate-at-point-gl ()
  "Translate current line and handle Japanese specially"
  (interactive)
  (if (equal google-translate-default-target-language "ja")
      (progn
        (select-current-line)
        (google-translate-at-point)
        (save-excursion
          (end-of-line)
          (open-line 1))
        (forward-line)
        (hiragana-region)
        (forward-line 2)
        (evil-org-open-below 1))
    (translate-and-insert-line)))

;; Reverse translation if prefix arg is provided
(defun my-google-translate-at-point()
  "Reverse translate if prefix"
  (interactive)
  (if current-prefix-arg
      (google-translate-at-point)
    (google-translate-at-point-reverse)))

  (map! :map evil-normal-state-map
    "C-k" nil)

;; Reverse translation function that inserts above current line
(defun google-translate-reverse-above ()
  "Translate current line in reverse direction and insert result above"
  (interactive)
  (let ((google-translate-default-source-language 
         google-translate-default-target-language)
        (google-translate-default-target-language 
         google-translate-default-source-language))
    (select-current-line)
    (google-translate-at-point)
    (beginning-of-line)
    (open-line 1)  ; Create one blank line above
    (yank)         ; Insert translation
    (forward-line 2))) ; Move down two lines after everything is done

:bind
("C-t" . google-translate-at-point-gl)
("C-l" . google-translate-at-point-gl)
("C-k" . google-translate-reverse-above))


(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "C-c") 'evil-normal-state)

(setq company-backends
  '(
    (
     company-files
     company-dabbrev
     company-keywords
     company-capf
     company-yasnippet
     )
    (company-abbrev company-dabbrev)
    ))
(setq gac-automatically-push-p t)
(setq gac-automatically-add-new-files-p t)
(setq gac-debounce-interval 10)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8) ;; also see `my-frame-config'
(set-keyboard-coding-system 'utf-8)
(set-locale-environment "en_US.UTF-8")
(setq-default buffer-file-coding-system 'utf-8)
(when (boundp 'default-buffer-file-coding-system) ;; obsolete since 23.2
  (setq default-buffer-file-coding-system 'utf-8))
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; Put this at the very end of your config.el
(after! evil
  ;; First remove all C-k bindings
  (general-unbind "C-k")
  (general-unbind evil-insert-state-map "C-k")
  (general-unbind evil-normal-state-map "C-k")
  (general-unbind evil-visual-state-map "C-k")
  
  ;; Then add our binding
  (map! :gi "C-k" #'google-translate-reverse-above
        :n  "C-k" #'google-translate-reverse-above
        :v  "C-k" #'google-translate-reverse-above))

;; Also ensure org-mode doesn't override it
(after! org
  (map! :map org-mode-map
        :gi "C-k" #'google-translate-reverse-above
        :n  "C-k" #'google-translate-reverse-above
        :v  "C-k" #'google-translate-reverse-above))
