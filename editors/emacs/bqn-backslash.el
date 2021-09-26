;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'quail)
(require 'bqn-symbols)

(quail-define-package "BQN-Z" "UTF-8" "⍉" t
                      "Input mode for BQN"
                      '(("\t" . quail-completion))
                      t                 ; forget-last-selection
                      nil               ; deterministic
                      nil               ; kbd-translate
                      t                 ; show-layout
                      nil               ; create-decode-map
                      nil               ; maximum-shortest
                      nil               ; overlay-plist
                      nil               ; update-translation-function
                      nil               ; conversion-keys
                      t                 ; simple
                      )

(defvar bqn--transcription-alist)
(defun bqn--update-key-prefix (symbol new)
  (quail-select-package "BQN-Z")
  (quail-install-map
   (let* ((prefix (string new))
          (bqn--transcription-alist
           (cl-loop for command in bqn--symbols
                    collect (cons (concat prefix (char-to-string (cl-third command)))
                                  (cl-second command)))))
     (quail-map-from-table
      '((default bqn--transcription-alist)))))
  (set-default symbol new))

(defun bqn--initialize-key-prefix (symbol new)
  (custom-initialize-default symbol new)
  (bqn--update-key-prefix symbol (eval new)))

(defcustom bqn-key-prefix ?\\
  "Set a character to serve as prefix key for BQN symbol input."
  :type 'character
  :group 'bqn
  :initialize #'bqn--initialize-key-prefix
  :set #'bqn--update-key-prefix)

(provide 'bqn-backslash)
