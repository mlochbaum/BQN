# Broken syntax
! % {⁼:5}
! % {𝕨𝕊˜𝕩,:×𝕩}
! % {𝕊𝕩:𝕩⁼; 𝕊⁼⁼𝕩:4}
! % {𝕊⁼˜:𝕩+𝕨}
! % {𝕊,⁼:𝕩-1}
! % {𝕊𝕩:⁼𝕩-1}
! % {𝕩; 𝕊𝕩⁼:÷𝕩}
! % {a‿b⁼Fn𝕩:1?b;𝕊a:a-1}
! % {_𝕣_⁼: 𝕗‿𝕘‿𝕩}
! % {𝔽⁼_𝕣𝕩: 𝔽⁼𝕩}

# Invalid header use
! % {o⁼:0}
! % {𝕊⁼𝕩:𝕨}
! % {𝕩 ; 𝕊⁼:𝕩}
! % {𝔽_𝕣 𝕩: 𝕘}
! % {𝔽_𝕣: 1+𝔽; 𝔽_𝕣⁼: 𝔽-⟜1}
! % {𝕗_𝕣_𝕘 ⁼: 3}
! % {𝕗_𝕣_𝕘˜⁼: 3}
! % {𝕊˜⁼𝕩: 𝕨-𝕩}
! % {𝔽_𝕣_𝔾˜⁼ 𝕩: 𝕗‿𝕘‿𝕩}

# Functions
3 %  { 𝕊⁼ : 𝕩-1}⁼4
1 %  {⋄Y⁼⋄: 𝕨-𝕩}⍟⊢¯1
! %  { 𝕊⁼ : 𝕩-𝕨}⁼1
! %  { 𝕊⁼ : 𝕩-1}1
4 % F←{𝕊⁼ : 𝕨÷𝕩 ; 𝕩;÷𝕨}⋄8 F⁼ 2
7 % ×˜⌾{𝕊⁼:𝕩-2; 1+𝕩}2
! % {𝕊a:1+a; 𝕊⁼a:a-1}⁼˜1
1 % {𝕊a:1+a; 𝕊⁼a:𝕨-a}⁼¯1
1 % {𝕊a:1+a;𝕨U⁼a:𝕨-a}⁼¯1
0 % {𝕨𝕊⁼𝕩: 5+(𝕊⁼𝕨)-2×𝕩}⁼´2‿3
6 % 4{A⁼:𝕨-𝕩;B˜⁼:𝕨+𝕩;C:𝕩}˜⁼2
3 % 2{𝕨𝕊˜⁼𝕩:𝕩-˜𝕨}˜⁼˜5
! %  {𝕨𝕊˜⁼𝕩:𝕨-𝕩}˜⁼1
! %  { 𝕊˜⁼ :𝕨-𝕩}˜⁼1
3 % 5‿6{𝕊a:1+a;a‿b F⁼c:F{b÷c}}⁼3
7 % {𝕨𝕊˜⁼𝕩:𝕨+2×𝕩; 𝕊⁼𝕩:𝕊⟜3⁼𝕩; 𝕊⁼1+𝕩} 1

# Modifiers
! % {Fn _𝕣𝕩: 0; 𝔽_𝕣⁼𝕩: Fn𝕩}
2 % -{𝔽_𝕣⁼𝕩: 5𝔽𝕩}⁼ 3
0 % 2-{a𝔽_r⁼b‿c: r=c}⁼ 3‿4
! % 2-{a𝔽_r⁼b‿c: r=c}⁼ 3‿4‿5
4 % 2⊸×{𝔽_𝕣⁼𝕩: 𝕊𝕊𝕩; 𝔽_𝕣𝕩:𝔽𝕩}⁼ 1
2 % -{𝔽_𝕣_𝔾⁼ 𝕩: 𝔽𝕩𝔾𝕩-6 ; 𝔽𝔾𝕩}÷⁼ 4
7 % 3 0{𝕨𝕗_𝕣_𝕘⁼𝕩: 1+(𝕊⁼𝕨)-𝕘_𝕣_𝕗⍟(-𝕘)𝕩}1⁼ 4
9 % 4 -{𝕨𝔽_𝕣˜⁼𝕩: 𝕩𝔽○(×˜)𝕨}˜⁼ 5
! % -{𝕨𝔽_𝕣˜⁼𝕩: 𝕗‿𝕩}˜⁼ 4
