# Headerless
! % 1;𝕩
! % ;
! % {⟨1;2⟩+𝕩}
! % {(𝔾𝕩;𝔾𝕨)}
! % {𝕨;2+𝕩}
! % {5;8}
! % 3{𝕗;-𝕗}
! % {𝕩;{3-𝕩}𝕨;𝕩}
! % {≍𝕩;}
! % {a←𝕩;a-𝕨}
6 % {2×𝕩;𝕨÷𝕩}3
2 % 1{𝕩;2}3
4 % 12{2×𝕩;,𝕨÷𝕩}3
7 % {d←𝕩×2,1+d,;!𝕨}3
3 % 3{a←𝕩⋄;⋄⋄a←𝕨}5
6 % a←2⋄9{𝕤,a←5,a;a×𝕩}3
! % ( {a←𝕩;a⇐𝕨}5).a
4 % (4{a←𝕩;a⇐𝕨}5).a
2 % {⟨b⟩←𝕩⋄b;𝕨,!0}{a⇐1+b⇐2}
9 % ×{𝕩𝔽𝕩;𝔽𝕨}3
1 % 9×{𝕩𝔾𝕩;𝕘,𝔽𝕨}!3
4 % ×˜{𝔽𝕩;𝕩}2
3 % 6-{𝔽𝕩;𝕨𝔾𝕩}÷2

# Overall structure
! % :
! % s:3
! % {𝕩;𝕊3:2}
! % {𝕨𝕊𝕩;Fn:𝕩-1}
! % {𝕩;𝕊𝕩:-𝕩;𝕨}
! % {𝕊𝕩:-𝕩;𝕨;𝕨}
! % {𝕊𝕩:-𝕩;𝕩;1+𝕩;2+𝕩}
! % {𝕩; ;𝕨}
! % {𝕊𝕩:𝕨}
! % {F:6;v:4}
! % {F:𝕩;v:4}
! % {a:1;a←2}
! % {_𝕣:÷3;4⋆5}
! % {_𝕣:𝔾𝕨}
! % {a o _r b:4;o _r:6}
! % {a‿𝕩:a+1}

# Labels
5 % -{imm:a←4,a-9}
3 % a←1⋄a+{v:a←2⋄b←3⋄a}
! % {l:1+l}
! % {𝕤:2+2}
! % {v:𝕩}
! % {{v:𝕩}}0
2 % {R:1(⊣R⍟(¬𝕨⊣0)+)𝕩}0
1 % {F:𝕤≡f}˜@
1 % F←{F:!0},1
0 % {F:𝕤↩↕2⋄=f}¯1
1 % {𝕊:𝕤↩↕2⋄=𝕤}¯1
1 % {𝕊:-𝕩}¯1
! % {F:_𝕣}
! % {𝕊:𝔽}
! % {F:𝔾}
! % {𝔽:-𝕩}¯1
1 % {Fn:𝕨-𝕩}¯1
4 % 3{Fn:𝕨-𝕩}¯1
4 % ×{_m:𝔽˜𝕩}2
3 % 12{_𝕣_:𝕗÷𝕘}4
3 % ¯3{_m_:-𝕗}2
! % {_r:𝔾}

# Syntax
! % {;2⋆𝕩}
! % {:{⋆˜𝕩}˜𝕩}
! % {-𝕩:𝕩}
! % {F𝔽: ÷𝕗}
! % {𝕨𝕊,:1,}
! % {_𝕣𝕗:0}
! % {_m𝕘:1}
! % {𝕗_𝕣_𝕘:𝕨‿𝕩}
! % {𝕘_𝕣_𝕗:𝕣}
! % {𝕗_𝕣_𝕗:@}
! % {,𝕨𝕊𝕊𝕩:{𝕩+1}𝕨}
! % {𝕨𝕊𝕩𝕩:𝕩}
! % {𝕨𝕨𝕊𝕩:𝕨}
! % {𝕨𝕣𝕩:𝕩}
! % ⟨@,{𝕨‿𝕩𝕊𝕩:@}⟩
! % {𝕊:𝕊:𝕩}
! % {𝔽 _𝕣: a‿b: 1}
! % {𝕨𝕊𝕩::@}
! % {𝕊0 1:𝕩}
! % {𝕊a:𝕩 ⋄ 𝕊b:𝕩}
! % {𝕊⟨a←b⟩:𝕩}
! % {𝔽_𝕣_1:1;𝔽_𝕣_𝔾:2}
! % {⟨a,b⟩_r:a‿b⊸⥊;a _r 𝕩: a‿a _r 𝕩}
! % {𝕊(A b):b}
! % {𝕊(w(x))‿y:w}
! % {⟨(a)(_b)⟩_op:b}

# Headers
5 % {𝕨𝕊𝕩:1+𝕩}4
4 % {𝕊a:a×𝕩}2
! % {A a:a}2
! % {F𝕩:f←𝕩}
2 % {𝕨Fn𝕩:1(⊣Fn⍟(¬𝕨⊣0)+)𝕩}0
! % {w𝕊𝕩:𝕩}3
3 % {{𝕨S𝕩:1+𝕩}}{𝔽}2
4 % 1{a B c:c B⍟a 2×a+c}0
5 % {𝕊n,:n+↩2,𝕩+↩1,n+𝕩}1
8 % 4{𝔽_m:2×𝕗}
6 % ×˜{𝔽_m𝕩:𝔽⊸-𝕩}3
8 % 1{𝕗_m:5{𝕩_m}⍟>2×𝕗}
2 % 0.5 {𝕗_c_𝔾,:𝔾𝕗,} ÷
3 % 6{𝔽 _𝕣_ G:𝕗÷𝕘}2
1 % {-÷}≡1-{𝕨𝕗_𝕣_𝕘𝕩:𝔽𝔾}÷2
! % 1-{𝕗_𝕣_𝕘𝕩:𝔽𝔾}÷2

# Headers and bodies
1 % {𝕊𝕩:0;𝕨𝕊𝕩:1}{(𝔽5)<(4𝔽5)}
3 % {𝕨A𝕩:𝕨≠𝕩;𝕨B𝕩:!0}"xyz"
5 % {{𝕨F𝕩:a←𝕩,{!a≡𝕩,a-3}𝕨;𝕊:!0}{𝔽_𝕣:𝕗˜}{2×𝕩;𝕨}4}
4 %   +⟜1{𝔽_r_𝔾 𝕩:𝔽𝕩; 𝕨𝔽_r_𝔾𝕩:𝕨𝔾𝕩}⋆ 3
8 % 2 +⟜1{𝔽_r_𝔾 𝕩:𝔽𝕩; 𝕨𝔽_r_𝔾𝕩:𝕨𝔾𝕩}⋆ 3
2 % +⟜1{F _r_ G:{𝕊𝕩:F𝕩; 𝕨𝕊𝕩:𝕨G𝕩}}⋆{2⊸𝔽÷𝔽}3
! % {𝕨Fail𝕩:𝕨;𝕩}@
3 % {·Dyad𝕩:𝕨;𝕩}3
3 % {1𝕊2:𝕨;𝕩}3
2 % {F x:0;2}˜1
! % {0:1;a:2}4

# Predicates
4 % {0 ? 3;4}
! % {2 ? 3;4}
! % {a←1?5;a}
! % {5;1<2?6}
! % {x←4⋄x=x?;4}
! % {(𝕩?2)+1;3}1
! % {𝕊:⟨1,𝕩?2,3⟩;𝕩}1
! % {·?2;3}
! % {a←1,a⇐?3;5}
2 % {a←2⋄4=×˜a,?a;6}
2 % a←2⋄{a>1?a<1?-a;a}
1 % -´{𝕩≤2?3×𝕩;𝕩}¨2‿5
! % {𝕩;𝕨<2?0;𝕨}
3 % 1{𝕨<𝕩?𝕨+𝕩;𝕩;𝕨}2
3 % 3{𝕨<𝕩?𝕨+𝕩;𝕩;𝕨}2
4 % ⟨4,2⟩{=𝕗?⊑𝕗;𝕗}
1 % 0 ({𝕩=1?0;1}¨≡=) 0‿1
9 % { 5=𝕩?0; ×˜𝕩 } 3
! % {⟨⟩:1; 1?1; a:2} 4

# Destructuring
2 % {𝕊a‿b:b-a}3‿5
! % {𝕊a‿b:𝕩}↕4
2 % {A‿_b_:b-a}3‿5
2 % 4{𝕨𝕊a‿b:𝕨-b÷a}3‿6
! % {a‿b:𝕩}↕4
3 % {𝕊a‿B:b-a;≠𝕩}3‿5‿6
1 % >´{⟨x⟩:1;𝕩:0}¨⟨2⟩‿6
3 % 1  {⟨a,b⟩_r𝕩:a+b×𝕩; a _r𝕩:a‿a _r 𝕩} 2
7 % 1‿3{⟨A,B⟩_r𝕩:a+b×𝕩; a _r𝕩:a‿a _r 𝕩} 2
({2:4;𝕩}¨≡⊢+2×2⊸=)↕4
⟨0‿1,2⟩≡{1‿b:b;𝕊:𝕩}¨+⟜<↕2
0‿1‿'c'‿3 ≡ {S a‿2:a;S a‿b:b}¨"abcd"∾¨↕4
4‿2‿4‿3 ≡ {𝕨𝕊0:4;1+𝕩;𝕩×𝕨}¨{𝔽∾3𝔽⊢}↕2
2 % 4 3{4 3 _𝕣_ 2 1:𝕨÷𝕘}2 1
4 % 2{⟨a,b⟩_r:a+b;a _r: a‿a _r}
55 % 1‿1{𝕗_r 1:0⊑𝕗 ; 𝕗_r 2:1⊑𝕗 ; _r: +´ 𝕗_r¨ 𝕩-1‿2} 10
34 % 1‿1{𝕗_r_𝕘 1:0⊑𝕗 ; 𝕗_r_𝕘 2:1⊑𝕗 ; _r_: 𝔾´ 𝕊¨ 𝕩-1‿2}+ 9
5 % {𝕊·:5}4
2 % 4‿3{a‿·_𝕣:(1⊑𝕗)-1}
<´{𝕊[]:1;0}∘↕¨1‿2⋈0‿3

# Namespace destructuring
2 % {b⇐3} ÷○{⟨a⟩:a+1; 𝕤,8} {a⇐3}
6 % {⟨al⇐a⟩:al+1; 𝕊:0} {a⇐5}
