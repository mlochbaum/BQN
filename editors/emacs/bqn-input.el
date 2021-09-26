;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'bqn-symbols)

(eval-and-compile
  (defun bqn--make-key-command-sym (n)
    (intern (concat "insert-sym-bqn-" n))))

(cl-macrolet ((make-insert-functions ()
             `(progn
                ,@(mapcar #'(lambda (command)
                              `(defun ,(bqn--make-key-command-sym (car command)) ()
                                 (interactive)
                                 (insert ,(cadr command))))
                          bqn--symbols))))
  (make-insert-functions))

(defun bqn--kbd (definition)
  (if (functionp #'kbd)
      (kbd definition)
    (eval `(kbd ,definition))))

(defun bqn--make-base-mode-map (prefix)
  (let ((map (make-sparse-keymap)))
    (dolist (command bqn--symbols)
      (let ((key (single-key-description (caddr command))))
        (define-key map (bqn--kbd (concat prefix key)) (bqn--make-key-command-sym (car command)))))
    (define-key map [menu-bar bqn] (cons "BQN" (make-sparse-keymap "BQN")))
    map))

;; value gets updated by initialization of bqn-mode-map-prefix
(defvar bqn--mode-map nil
  "The keymap for ‘bqn-mode’.")

(defun bqn--set-mode-map-prefix (symbol new)
  "Recreate the prefix and the keymap."
  (set-default symbol new)
  (setq bqn--mode-map (bqn--make-base-mode-map new)))

(defcustom bqn-mode-map-prefix "s-"
  "The keymap prefix for ‘bqn--mode-map’ used both to store the new value using
  ‘set-create’ and to update ‘bqn--mode-map’ using `bqn--make-base-mode-map'.
  Kill and re-start your BQN buffers to reflect the change."
  :type 'string
  :group 'bqn
  :set 'bqn--set-mode-map-prefix
  :initialize 'custom-initialize-set)

(provide 'bqn-input)
