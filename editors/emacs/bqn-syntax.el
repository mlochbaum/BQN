;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'bqn-symbols)

(defface bqn-block-face
  '((t (:inherit font-lock-function-name-face)))
  "Face used for BQN curly braces."
  :group 'bqn)

(defface bqn-paren-face
  '((t (:inherit default)))
  "Face used for BQN parentheses."
  :group 'bqn)

(defface bqn-header-face
  '((t (:inherit default)))
  "Face used for BQN header delimiters : and ; ."
  :group 'bqn)

(defface bqn-list-face
  '((t (:inherit font-lock-builtin-face)))
  "Face used for BQN list characters: angle brackets and ligature."
  :group 'bqn)

(defface bqn-separator-face
  '((t (:inherit font-lock-builtin-face)))
  "Face used for BQN expression separators."
  :group 'bqn)

(defface bqn-arrow-face
  '((t (:inherit 'default)))
  "Face used for BQN assignment and return arrows."
  :group 'bqn)

(defface bqn-function-face
  '((t (:inherit font-lock-type-face)))
  "Face used for BQN functions."
  :group 'bqn)

(defface bqn-one-modifier-face
  '((t (:inherit font-lock-preprocessor-face)))
  "Face used for BQN 1-modifiers."
  :group 'bqn)

(defface bqn-two-modifier-face
  '((t (:inherit font-lock-keyword-face)))
  "Face used for BQN 2-modifiers."
  :group 'bqn)

(defface bqn-subject-face
  '((t (:inherit font-lock-variable-name-face)))
  "Face used for BQN subjects."
  :group 'bqn)

(defface bqn-nothing-face
  '((t (:inherit font-lock-constant-face)))
  "Face used for BQN Nothing (·)."
  :group 'bqn)

(defface bqn-number-face
  '((t (:inherit font-lock-constant-face)))
  "Face used for BQN numeric literals."
  :group 'bqn)

(defvar bqn--token-syntax-types '((("'.'\\|@" . font-lock-string-face)
                                   ("[{}]" . 'bqn-block-face)
                                   ("[()]" . 'bqn-paren-face)
                                   ("[:;?]" . 'bqn-header-face)
                                   ("[⟨⟩‿]" . 'bqn-list-face)
                                   ("[⋄,]" . 'bqn-separator-face)
                                   ("[←⇐↩→]" . 'bqn-arrow-face)
                                   ("[𝔽𝔾𝕎𝕏𝕊+×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍕⍎-]\\|•?\\_<[A-Z][A-Z_a-z0-9π∞¯]*\\_>" . 'bqn-function-face)
                                   ("[˙˜˘¨⌜⁼´˝`]\\|•?\\_<_[A-Za-z][A-Z_a-z0-9π∞¯]*\\|_𝕣\\_>" . 'bqn-one-modifier-face)
                                   ("[∘○⊸⟜⌾⊘◶⎉⚇⍟⎊]\\|_𝕣_\\|•?\\_<_[A-Za-z][A-Z_a-z0-9π∞¯]*_\\_>" . 'bqn-two-modifier-face)
                                   ("[𝕗𝕘𝕨𝕩𝕤𝕣]\\|•\\|•?\\_<[a-z][A-Z_a-z0-9π∞¯]*\\_>" . 'bqn-subject-face)
                                   ("·" . 'bqn-nothing-face)
                                   ("\\_<¯?\\(\\([0-9]+\\.\\)?[0-9]+\\(e¯?[0-9]+\\)?\\|π\\|∞\\)\\(i¯?\\(\\([0-9]+\\.\\)?[0-9]+\\(e¯?[0-9]+\\)?\\|π\\|∞\\)\\)?\\_>" . 'bqn-number-face)
                                   ("[^ \r\n]" . 'error))
                                  nil nil nil))

(defvar bqn--syntax-table
  (let ((table (make-syntax-table)))
    (cl-loop for s in bqn--symbols
          do (modify-syntax-entry (aref (cl-second s) 0) "." table))
    (cl-loop for s in (append "$%&*+-/<=>|" nil)
          do (modify-syntax-entry s "." table))
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?#  "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?⟨  "(" table)
    (modify-syntax-entry ?⟩  ")" table)
    (modify-syntax-entry ?⟩  ")" table)
    (modify-syntax-entry ?¯  "_" table)
    (modify-syntax-entry ?π  "_" table)
    (modify-syntax-entry ?∞  "_" table)
    table)
  "Syntax table for ‘bqn-mode’.")

(provide 'bqn-syntax)
