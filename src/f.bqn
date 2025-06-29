# Format an array to a string including newlines
{
  ⟨Type,Decomp,FF,FN⟩←𝕩
  ReprAtom ← <⟜@◶⟨@⊸≠◶⟨"@","'"⊸(∾∾⊣)⟩,FN⟩

  # Vertical padding for arrays of rank greater than 2
  PadCount ← {
    # Empty lines after each row: 1 if it's at the end of a 2-cell, plus
    # 1 if it's at the end of a 2-cell and a 3-cell, and so on
    # But none at the very end
    0⌾(¯1⊸⊑) ⥊ 𝕨 +⎉¯1‿∞´ ×⌜˜`⌾⌽ (-𝕩)↑¨1
  }
  PadV ← {
    # Leading shape and padding count
    p ← PadCount 1 ⌈ ls ← ¯1↓≢𝕩
    # If 𝕩 has cells, pad by selection; if it's empty, there are only
    # pads but selection would try to get cells (1⌈ above), so overtake.
    Pad ← {(»⊸<⊸×/0∾1+𝕨) ⊏ ' '¨∘⊏⊸∾𝕩}
    p (0<≠∘⊢)◶⟨+´⊸↑,Pad⟩ ((×´ls)∾¯1↑≢𝕩) ⥊ 𝕩
  }⍟(2 < =)
  PadVMixed ← {
    # PadV, but with 2-cells enclosed: they might have different lengths
    ∾ (1 PadCount ≢𝕩) (⊢∾≍⟜(¯1⊑≢)⥊' '˙)¨ ⥊𝕩
  }

  # Horizontal padding: just some spaces on either side
  PadH ← { s←⟨≠𝕩,𝕨⟩⥊' ' ⋄ ∾≍⟨s,𝕩,s⟩ }

  # Add a frame to padded data
  Enframe ← ∨○(1⊸≠)⟜≠◶{∨´2=+`-˝"⟨⟩"=⌜⊏𝕩}‿1◶{
    # One-line version
    ≍"⟨"∾(¯1↓1↓⊏𝕩)∾"⟩"
  }‿{
    # General case
    t ← "┌" ∾ (5⊸<)◶⟨⥊"·─"⊏˜1⌊⊢,FN⟩𝕨
    l ← (≠t) ⌈ ¯1 ⊑ ≢𝕩
    ∾ ⟨≍l↑t, ((0⌈4⌊𝕨-1)⊑"·╵╎┆┊")⌾⊑l↑˘𝕩, ≍l-⊸↑"┘"⟩
  }

  FmtEmpty ← (0‿0≢≢)◶("┌┐"≍"└┘")‿(((2≠=)∨0=≠)◶{
    '┐'⌾(0‿¯1⊸⊑) 2 Enframe 1 PadH ' '¨𝕩
  }‿{
    ≍(1<≠)◶⟨"⟨⟩",'↕'⌾⊑·∾·"‿"⊸∾¨FN¨⟩≢𝕩
  })∘⊢
  
  AlignNums ← {
    SameExp ← ⊣`⊸≡∘⥊ (∨`'e'⊸=)⊸/¨
    FrontPad ← ⌈´∘⥊⊸- ⊑∘⊐⟜'.'¨
    Wid ← SameExp◶⟨(⌈´∘⥊⊣¨⊢)≠¨, ≠¨+FrontPad⟩ ⊏¨
    ⍉ -∘Wid˘⊸(↑˘¨)⌾(𝕨⊸/) ⍉⁼𝕩
  }

  PaddingJoin ← {
    s ← ≢¨ 𝕩
    w ← (0<=)◶⟨⥊,⌈˝⍟(=-1˙)⟩1⊑¨s
    h ← ⌈˝⎉1⍟(0<=) ⊑¨s
    o ← <∘∾⎉2 ≍⍟(0⌈2-=) (h ⋈⌜ w¬(-≠w)↑1) ↑¨ 𝕩
    2 PadH (1⊸⌽⊸≡⥊h)◶⟨PadVMixed,PadV∘>⟩ o
  }

  FmtNonEmpty ← {
    r ← =𝕩
    n ← (1<=)◶⟨↕0, ∧˝⍟(=-1˙) 1=Type¨⟩ 𝕩  # Numeric columns
    Join ← r Enframe · PaddingJoin n⊸AlignNums⍟(0<+´n)
    𝕨 (∨´<⟜∞)◶(Join <⊸(Fmt¨))‿{
      p ← ⟨r>1,2⟩  # Outer padding
      o ← ¯1((0+⌜´(1(1+×)`⊢)⌾⌽×↕¨)∘↓⋈⌜2×↕∘⊑)≢𝕩  # Offset
      E ← (1‿1⥊'…')˙
      f ← o (𝕨-p)⊸-⊸(⊣ E∘⊢⍟(∨´<⟜≢) (∨´≤⟜0)◶Fmt‿E)¨ 𝕩
      Join f
    } 𝕩
  }

  FmtCharArr ← {
    r ← =𝕩 ⋄ 𝕩 ↩ ><¨0↓𝕩  # Ensure rank>0 and ' ' for fill
    k ← ∞⍟(0⊸=) -≠ c ← ¯1↓≢𝕩
    q ← "'"""⊑˜0<r
    # Escape quotes in strings (rank 1) and substitute control chars
    # with control pictures for other ranks.
    CSub ← { 𝕩 + (𝕩(=×'␡'-⊢)@+127) + ('␀'-@)×𝕩<@+32 }
    𝕩 ↩ (1≠r)◶⟨(1+q=⊢)⊸/,Csub⟩ 𝕩
    (r Enframe 1 PadH PadV)⍟(1≠r) ≍ (q⌾⊑c⥊(¯1⊑1∾c)↑'·') ∾⎉k 𝕩 ∾⎉k c-⊸↑q
  }

  FmtArr ← (0<≠)◶⟨2,∧´2=Type¨⟩∘⥊∘⊢◶FmtNonEmpty‿FmtCharArr‿FmtEmpty

  # Format data type
  FmtDat ← (0=Type∘⊢)◶⟨≍ ReprAtom∘⊢, FmtArr⟩

  # Word-forming characters need to be separated by spaces
  IsWordChar ← ∊⟜(∧"¯π∞_") ∨ (⥊∧"0AaÀàØø"+0≍˘10∾2/26‿23‿7)⊸(2|⍋)

  # Format part of a compound operation; return precedence‿string
  Paren ← "("∾∾⟜")"
  _dispOp_ ← {
    FmtComp ← Type (3≤⊣)◶⟨0⋈·𝔽⊢, 𝕊⟩ ⊢
    k ← ⊑ d ← Decomp 𝕩
    p ← k ⊑ "00321111"-'0'
    JW ← ∾ (∧˝∘IsWordChar (⊢´¨¯1⊸↓)≍(⊣´¨1⊸↓)) 0⊸∾⊸(↑⟜" "⊸∾¨)⍟(∨´⊣) ⊢
    FromComp ← JW (⌽⍟(p>1)·-0=↕∘≠) (+⟜⊑Paren∘⊢⍟((2⌊p)≤⊣)1⊸⊑)⟜FmtComp¨ ⊢
    s ← (2⌊|k)◶⟨⥊∘FF𝕩˙,𝕨𝔾⊢,FromComp⟩ 1↓d
    s ↩ ∾⟜"{𝔽}"⍟(3>·Type ¯1⊑d˙)⍟(2≤p) s
    p‿s
  }
  arr ← "*array*"
  FmtOp ← ≍1⊑ (1=≠)◶⟨arr,⊏⟩∘(∞‿∞⊸FmtDat) _dispOp_ (=⟜2◶⟨FF⊑∘⊢,arr⟩)

  # Format any value to character matrix
  Fmt ← {
    t ← Type𝕩
    𝕨 (3≤t)◶⟨FmtDat,t⊸FmtOp⟩ 𝕩
  }
  Trunc ← {
    c ← 𝕨<s←≢ f ← 𝕩
    𝕨 {l←c-˜𝕨⌊s ⋄ ls←⋈⌜´l∾⟜(⥊⟜1)¨c ⋄ ∾ ls ⥊¨ (l↑f)⌾⊑ '…'¨ ls}⍟(∨´c) f
  }
  FmtW ← {
    m ← "•Fmt: 𝕨 must be a list of up to two numbers (width, height)"
    m ! (1≥=)◶⟨0,2≥≠⟩ 𝕨
    (⌽𝕨⊢⊘»∞‿∞) (⊣ Trunc Fmt) 𝕩
  }

  # Represent as string
  RR ← {Repr𝕩}
  ReprList ← (0<≠)◶⟨"⟨⟩",(⌈´(2‿1‿0»7⥊2)⊏˜Type⌜)◶⟨
    '"' (⊣∾((1+=)/⊢)∾⊣) ⊢
    (1<≠)◶⟨"⟨"∾"⟩"«∾,1↓∾⟩("‿"∾ReprAtom)¨
    "⟨"∾"⟩"«·∾(","∾RR)¨
  ⟩⟩
  ReprArr ← (2⌊=)◶⟨Paren"<"∾RR∘⊑,ReprList,Paren≢∾⟜"⥊"⊸∾○ReprList⥊⟩
  ReprDat ← (0=Type)◶⟨ReprAtom,ReprArr⟩
  ReprOp ← 1⊑ RR _dispOp_ (!"Can't represent "∾"block"‿"namespace"⊑˜6=⊣)
  Repr ← Type (3≤⊣)◶⟨ReprDat⊢,ReprOp⟩ ⊢

  # Convert Fmt from matrix to string
  ⟨¯1↓·⥊ ∾⟜(@+10)˘∘FmtW, Repr⟩
}
