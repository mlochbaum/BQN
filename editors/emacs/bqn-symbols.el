;;; -*- lexical-binding: t -*-

(defvar bqn--symbols '(;; Top row
                       ;; `
                       ("high-tilde" "˜" ?`)
                       ("logical-not" "¬" ?~)
                       ;; 1
                       ("breve" "˘" ?1)
                       ("circle-notch" "⎉" ?!)
                       ;; 2
                       ("diaeresis" "¨" ?2)
                       ("circled-diaeresis" "⚇" ?@)
                       ;; 3
                       ("high-equals" "⁼" ?3)
                       ("circle-star" "⍟" ?#)
                       ;; 4
                       ("corner" "⌜" ?4)
                       ("circle-corner" "◶" ?$)
                       ;; 5
                       ("acute" "´" ?5)
                       ("circle-slash" "⊘" ?%)
                       ;; 6
                       ("double-acute" "˝" ?6)
                       ("circle-triangle" "⎊" ?^)
                       ;; 7
                       ("hydrant" "⍎" ?&)
                       ;; 8
                       ("infinity" "∞" ?8)
                       ("thorn" "⍕" ?*)
                       ;; 9
                       ("high-minus" "¯" ?9)
                       ("open-angle" "⟨" ?\()
                       ;; 0
                       ("bullet" "•" ?0)
                       ("close-angle" "⟩" ?\))
                       ;; -
                       ("division-sign" "÷" ?-)
                       ("root" "√" ?_)
                       ;; =
                       ("multiplication-sign" "×" ?=)
                       ("star" "⋆" ?+)

                       ;; First row
                       ;; q
                       ("circle-stile" "⌽" ?q)
                       ("down-left-arrow" "↙" ?Q)
                       ;; w
                       ("double-w" "𝕨" ?w)
                       ("double-upper-w" "𝕎" ?W)
                       ;; e
                       ("epsilon" "∊" ?e)
                       ("epsilon-underbar" "⍷" ?E)
                       ;; r
                       ("up-arrow" "↑" ?r)
                       ("double-r" "𝕣" ?R)
                       ;; t
                       ("logical-and" "∧" ?t)
                       ("up-grade" "⍋" ?T)
                       ;; y
                       ;; u
                       ("square-cup" "⊔" ?u)
                       ;; i
                       ("open-square" "⊏" ?i)
                       ("open-square-underbar" "⊑" ?I)
                       ;; o
                       ("close-square" "⊐" ?o)
                       ("close-square-underbar" "⊒" ?O)
                       ;; p
                       ("pi" "π" ?p)
                       ("iota" "⍳" ?P)
                       ;; [
                       ("left-arrow" "←" ?\[)
                       ("left-tack" "⊣" ?{)
                       ;; ]
                       ("right-arrow" "→" ?\])
                       ("right-tack" "⊢" ?})
                       ;; \
                       ("backslash" "\\" ?\\)

                       ;; Second row
                       ;; a
                       ("circle-backslash" "⍉" ?a)
                       ("up-left-arrow" "↖" ?A)
                       ;; s
                       ("double-s" "𝕤" ?s)
                       ("double-upper-s" "𝕊" ?S)
                       ;; d
                       ("up-down-arrow" "↕" ?d)
                       ;; f
                       ("double-f" "𝕗" ?f)
                       ("double-upper-f" "𝔽" ?F)
                       ;; g
                       ("double-g" "𝕘" ?g)
                       ("double-upper-g" "𝔾" ?G)
                       ;; h
                       ("left-loop" "⊸" ?h)
                       ("left-chevron" "«" ?H)
                       ;; j
                       ("jot" "∘" ?j)
                       ;; k
                       ("circle" "○" ?k)
                       ("circle-jot" "⌾" ?K)
                       ;; l
                       ("right-loop" "⟜" ?l)
                       ("right-chevron" "»" ?L)
                       ;; ;
                       ("diamond" "⋄" ?\;)
                       ("middle-dot" "·" ?:)
                       ;; '
                       ("left-hook-arrow" "↩" ?')
                       ("high-dot" "˙" ?\")

                       ;; Third row
                       ;; z
                       ("zigzag" "⥊" ?z)
                       ;; x
                       ("double-x" "𝕩" ?x)
                       ("double-upper-x" "𝕏" ?X)
                       ;; c
                       ("down-arrow" "↓" ?c)
                       ;; v
                       ("logical-or" "∨" ?v)
                       ("down-grade" "⍒" ?V)
                       ;; b
                       ("left-floor" "⌊" ?b)
                       ("left-ceiling" "⌈" ?B)
                       ;; n
                       ;; m
                       ("identical-to" "≡" ?m)
                       ("not-identical-to" "≢" ?M)
                       ;; ,
                       ("join" "∾" ?,)
                       ("less-than-or-equal-to" "≤" ?<)
                       ;; .
                       ("couple" "≍" ?.)
                       ("greater-than-or-equal-to" "≥" ?>)
                       ;; /
                       ("not-equal-to" "≠" ?/)
                       ("left-double-arrow" "⇐" ??)

                       ;; Space bar
                       ("ligature" "‿" ? )
                       ))

(provide 'bqn-symbols)
