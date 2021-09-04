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
      (let ((key-sequence (caddr command)))
        (dolist (s (if (listp key-sequence) key-sequence (list key-sequence)))
          (define-key map (bqn--kbd (concat prefix s)) (bqn--make-key-command-sym (car command))))))
    (define-key map [menu-bar bqn] (cons "BQN" (make-sparse-keymap "BQN")))
    map))

(defun bqn--make-bqn-mode-map ()
  (bqn--make-base-mode-map bqn-mode-map-prefix))

(defun bqn--set-mode-map-prefix (symbol new)
  "Recreate the prefix and the keymap."
  (set-default symbol new)
  (setq bqn--mode-map (bqn--make-bqn-mode-map)))

(defcustom bqn-mode-map-prefix "s-"
  "The keymap prefix for ‘bqn--mode-map’ used both to store the new value using
  ‘set-create’ and to update ‘bqn--mode-map’ using `bqn--make-bqn-mode-map'.
  Kill and re-start your BQN buffers to reflect the change."
  :type 'string
  :group 'bqn
  :set 'bqn--set-mode-map-prefix)

(defvar bqn--mode-map (bqn--make-bqn-mode-map)
  "The keymap for ‘bqn-mode’.")

(provide 'bqn-input)
