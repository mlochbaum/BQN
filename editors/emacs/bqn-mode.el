;;; bqn-mode --- Emacs mode for BQN -*- lexical-binding: t -*-
;;;
;;; Commentary:
;;;
;;; Emacs mode for BQN: currently keymap only
;;;
;;; There are two ways to access the BQN keymap:
;;; - When editing a BQN file, use keys with the super (s-) modifier.
;;; - Enable backslash prefixes by entering C-\ (‘toggle-input-method’)
;;;   then BQN-Z. Then enter backslash \ before a key.
;;;
;;; Code:


;;;###autoload
(defgroup bqn nil
  "Major mode for interacting with the BQN interpreter."
  :prefix 'bqn
  :group 'languages)

;;;
;;;  Keymap functions
;;;

(require 'cl)
(require 'bqn-symbols)

(defun bqn--make-key-command-sym (n)
  (intern (concat "insert-sym-bqn-" n)))

(macrolet ((make-insert-functions ()
             `(progn
                ,@(mapcar #'(lambda (command)
                              `(defun ,(bqn--make-key-command-sym (car command)) ()
                                 (interactive)
                                 (insert ,(cadr command))))
                          bqn--symbols))))
  (make-insert-functions))

(defun bqn-insert-spc ()
  "Insert a space. This is needed so that one can type a space
character when using the super-prefixed characters."
  (interactive)
  (insert " "))

(defun bqn--kbd (definition)
  (if (functionp #'kbd)
      (kbd definition)
    (eval `(kbd ,definition))))

(defun bqn--make-base-mode-map (prefix)
  (let ((map (make-sparse-keymap)))
    (dolist (command bqn--symbols)
      (let ((key-sequence (caddr command)))
        (dolist (s (if (listp key-sequence) key-sequence (list key-sequence)))
          (define-key map (bqn--kbd (concat prefix s)) (bqn--make-key-command-sym (car command))))))
    (define-key map (kbd (concat prefix "SPC")) 'bqn-insert-spc)
    (define-key map [menu-bar bqn] (cons "BQN" (make-sparse-keymap "BQN")))
    map))

(defun bqn--make-bqn-mode-map ()
  (bqn--make-base-mode-map bqn-mode-map-prefix))

(defun bqn--set-mode-map-prefix (symbol new)
  "Recreate the prefix and the keymap."
  (set-default symbol new)
  (setq bqn-mode-map (bqn--make-bqn-mode-map)))

(defcustom bqn-mode-map-prefix "s-"
  "The keymap prefix for ‘bqn-mode-map’ used both to store the new value
using ‘set-create’ and to update ‘bqn-mode-map’ using
  `bqn--make-bqn-mode-map'. Kill and re-start your BQN buffers to reflect the change."
  :type 'string
  :group 'bqn
  :set 'bqn--set-mode-map-prefix)

(defvar bqn-mode-map (bqn--make-bqn-mode-map)
  "The keymap for ‘bqn-mode’.")

;;;
;;;  Define the mode
;;;

(require 'bqn-input)
(require 'bqn-syntax)

;;;###autoload
(define-derived-mode bqn-mode prog-mode "BQN"
  "Major mode for editing BQN files."
  :syntax-table bqn--syntax-table
  :group 'bqn
  (use-local-map bqn-mode-map)
  (setq-local font-lock-defaults bqn--token-syntax-types)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.bqn\\'" . bqn-mode))

;;;###autoload
(add-to-list 'interpreter-mode-alist '("bqn" . bqn-mode))

(with-eval-after-load 'speedbar
  (speedbar-add-supported-extension ".bqn"))

(provide 'bqn-mode)
