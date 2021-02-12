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

(require 'bqn-input)
(require 'bqn-backslash)
(require 'bqn-syntax)

;;;###autoload
(defgroup bqn nil
  "Major mode for interacting with the BQN interpreter."
  :prefix 'bqn
  :group 'languages)

;;;###autoload
(define-derived-mode bqn-mode prog-mode "BQN"
  "Major mode for editing BQN files."
  :syntax-table bqn--syntax-table
  :group 'bqn
  (use-local-map bqn--mode-map)
  (setq-local font-lock-defaults bqn--token-syntax-types)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.bqn\\'" . bqn-mode))

;;;###autoload
(add-to-list 'interpreter-mode-alist '("bqn" . bqn-mode))

(with-eval-after-load 'speedbar
  (speedbar-add-supported-extension ".bqn"))

(provide 'bqn-mode)
