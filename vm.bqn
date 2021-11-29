MakeVar ← { program 𝕊 name:
  v←@
  Get  ⇐ !∘"Runtime: Variable referenced before definition"
  SetU ⇐ !∘"↩: Variable modified before definition"
  SetN ⇐ {
    Get ↩ {𝕤⋄v}
    (SetU ↩ {v↩𝕩}) 𝕩
  }
  SetQ ⇐ 0∘SetN
  GetC ⇐ {
    r ← Get𝕩
    Get↩SetU↩SetN↩!∘"Internal error: Variable used after clear"
    r
  }
  GetF ⇐ {program 𝕩.Field name}
}
vnot ← { SetU⇐SetN⇐⊢ ⋄ SetQ⇐0˙ }
MakeEnv ← { 𝕊p‿v‿n‿e:
  ns ← v-≠n  # Number of special names
  parent ⇐ p
  program ⇐ p.program
  vars ⇐ program⊸MakeVar¨ (ns⥊¯1) ∾ n
  MakeNS ⇐ {𝕤
    v ← @ ⊣´¨ n ⊔ ns↓vars  # Lookup table
    Field ⇐ {𝕨𝕊i:
      cross ← 𝕨 { 𝕨1⊘≡𝕩 ? ⊢ ; ⊑ 𝕩.names ⊐ ⊏⟜𝕨.names } program
      (Cross i) ⊑ v
    }
  }
}

VO ← { d←𝕏@, s←𝕏@, s⊑·{𝕩.vars}{𝕩.parent}⍟d }

nothing  ← {⇐}
skipMark ← {⇐}

Namespace ← {𝕩.MakeNS@}
ReadNS ← { e‿i 𝕊 𝕩:
  "Key lookup in non-namespace" ! 6=•Type𝕩
  (e.program 𝕩.Field i).Get @
}

ref ← {
  Matcher ⇐ {𝕊 const:
    SetQ ⇐ const˙ ≢ ⊢
  }
  Array ⇐ {𝕊 arr:
    Get  ⇐ {𝕩.Get@}¨ arr˙
    _set_ ← {S _𝕣_ e:
      Err ← {(e∾": "∾𝕩)!e≡@ ⋄ ⟨1⟩}
      {
        0=•Type𝕩 ? arr ≡○≢◶⟨Err∘"Target and value shapes don't match", S¨⟩ 𝕩 ;
        # TODO "Cannot extract non-name from namespace" if 𝕨.GetF doesn't exist
        6=•Type𝕩 ? S⟜({(𝕨.GetF 𝕩).Get@}⟜𝕩)¨ arr ;
        Err "Multiple targets but atomic value"
      }
    }
    SetN ⇐    {𝕨.SetN𝕩}_set_"←"
    SetU ⇐    {𝕨.SetU𝕩}_set_"←"
    SetQ ⇐ ∨´ {𝕨.SetQ𝕩}_set_@⎊⟨1⟩ # TODO fix GetF errors and avoid ⎊
  }
  Alias ⇐ {env‿name 𝕊 r:
    SetN‿SetU‿SetQ ⇐ r
    GetF ⇐ {env.program 𝕩.Field name}
  }
}

Get ← {𝕩.Get @}⚇0

MakeStack ← {
  s ← 𝕩                          # Stack (a list)
  cont ⇐ 1                       # Whether to continue execution
  rslt ⇐ skipMark                # Result: skipMark to abort current body
  Push ⇐ {s∾↩<𝕩}                 # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Peek ⇐ {𝕤⋄¯1⊑s}                # Return but don't pop top value
  Ret  ⇐ {rslt↩𝕩 ⋄ cont↩0 ⋄ "Internal compiler error: Wrong stack size"!𝕨≥≠s}
  Skip ⇐ {𝕤⋄       cont↩0}
}

ops ← ((!∘"Unknown opcode")˙⊣´⊢)¨ ⊔˝ ⍉> ⟨
  # Constants and drop
   0‿{i←𝕏@ ⋄ {s𝕊e: s.Push         i⊑e.program.consts } }
   1‿{i←𝕏@ ⋄ {s𝕊e: s.Push e {𝕎𝕩}˜ i⊑e.program.blocks } }
   6‿(       {s𝕊e: s.Pop 1 }˙)
  # Returns
   7‿(       {s𝕊e: 0 s.Ret ⊑s.Pop 1 }˙)
   8‿(       {s𝕊e: 1 s.Ret Namespace e }˙)
  # Arrays
  11‿{i←𝕏@ ⋄ {s𝕊e: s.Push           ⌽s.Pop i } }
  12‿{i←𝕏@ ⋄ {s𝕊e: s.Push ref.Array ⌽s.Pop i } }
  # Application
  16‿(       {s𝕊e: s.Push {   f‿x:   F x }   s.Pop 2 }˙)
  17‿(       {s𝕊e: s.Push { w‿f‿x: w F x }   s.Pop 3 }˙)
  20‿(       {s𝕊e: s.Push {   g‿h:   G H }   s.Pop 2 }˙)
  21‿(       {s𝕊e: s.Push { f‿g‿h: F G H }   s.Pop 3 }˙)
  26‿(       {s𝕊e: s.Push { f‿m  : F _m    } s.Pop 2 }˙)
  27‿(       {s𝕊e: s.Push { f‿m‿g: F _m_ g } s.Pop 3 }˙)
  # Application with Nothing
  18‿(       {s𝕊e: s.Push {   f‿x:                     F⍟(nothing⊸≢) x } s.Pop 2 }˙) # Like 16
  19‿(       {s𝕊e: s.Push { w‿f‿x: (nothing≢w˙)◶⟨F,w˙⊸F⟩⍟(nothing⊸≢) x } s.Pop 3 }˙) # Like 17
  23‿(       {s𝕊e: s.Push { f‿g‿h: {f≡nothing?G H;F G H}               } s.Pop 3 }˙) # Like 21
  22‿(       {s𝕊e: "Left argument required" ! nothing≢s.Peek@ }˙)
  # Variables
  32‿{v←VO𝕩⋄ {s𝕊e: s.Push (V e).Get @ } }
  34‿{v←VO𝕩⋄ {s𝕊e: s.Push (V e).GetC@ } }
  33‿{v←VO𝕩⋄ {s𝕊e: s.Push  V e        } }
  # Headers
  42‿(       {s𝕊e: {0:s.Skip@; 1:@; 𝕊:!"Predicate value must be 0 or 1"} ⊑s.Pop 1 }˙)
  43‿(       {s𝕊e: s.Push ref.Matcher ⊑s.Pop 1 }˙)
  44‿(       {s𝕊e: s.Push vnot }˙)
  # Assignment
  47‿(       {s𝕊e: s.Skip⍟⊢{r‿  v: r.SetQ   v           } s.Pop 2 }˙)  # r:
  48‿(       {s𝕊e: s.Push { r‿  v: r.SetN⊸⊢ v           } s.Pop 2 }˙)  # r  ←v
  49‿(       {s𝕊e: s.Push { r‿  v: r.SetU⊸⊢ v           } s.Pop 2 }˙)  # r  ↩v
  50‿(       {s𝕊e: s.Push { r‿f‿x: r.SetU⊸⊢ (r.Get@)F x } s.Pop 3 }˙)  # r F↩x
  51‿(       {s𝕊e: s.Push { r‿f  : r.SetU⊸⊢ F r.Get@    } s.Pop 2 }˙)  # r F↩
  # Namespaces
  64‿{i←𝕏@ ⋄ {s𝕊e: s.Push e‿i ReadNS    ⊑s.Pop 1 } }
  66‿{i←𝕏@ ⋄ {s𝕊e: s.Push e‿i ref.Alias ⊑s.Pop 1 } }
⟩

RunBC ← { bc‿pos‿env:
  Next ← {𝕤⋄ (pos+↩1) ⊢ pos⊑bc }
  stack ← MakeStack ⟨⟩
  Step ← {𝕊:
    op ← (Next@) ⊑ ops
    op ↩ Op next
    stack Op env
    stack.cont
  }
  _while_ ← {𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}
  Step _while_ ⊢ 1
  stack.rslt
}

{ VM bc‿consts‿blockInfo‿bodyInfo‿loc‿token:

  bodies ← {start‿vars‿names‿export:
    {parent 𝕊 args:
      env ← MakeEnv parent‿vars‿names‿export
      (⊢ {𝕩.SetN 𝕨}¨ ≠↑env.vars˙) args
      RunBC bc‿start‿env
    }
  }¨ bodyInfo

  blocks ← {type‿imm‿body:
    inner ← imm ⊑ type ⊑ ⟨
      2⥊⟨{𝕊n: N ⟨⟩}⟩
      {𝕊n: {d←N 𝕣‿𝕗  ⋄𝕨D𝕩}}‿{𝕊n: {N 𝕣‿𝕗  }}
      {𝕊n: {d←N 𝕣‿𝕗‿𝕘⋄𝕨D𝕩}}‿{𝕊n: {N 𝕣‿𝕗‿𝕘}}
    ⟩
    outer ← imm ⊑ ⟨
      {
        m‿d: {𝕊v: {M 𝕤‿𝕩‿nothing∾v;D 𝕤‿𝕩‿𝕨∾v}} ;
        ⟨b⟩: {𝕊v: {B 𝕤‿𝕩‿(𝕨⊣nothing)∾v}}
      }
      ⊑
    ⟩

    nmc ← "No matching case"
    Then ← {first 𝕊 next: {skipMark≢r←𝕨First𝕩 ? r ; 𝕨Next𝕩}}
    run ← {
      1=•Type 𝕩 ?
      ⟨(𝕩⊑bodies) Then {!∘nmc}⟩
    ;
      "Internal compiler error: Invalid body indices" ! 1==𝕩
      ! (≠𝕩) ≡ 2-imm
      e ← {imm ? ⟨nmc⟩ ;
        (0=≠¨𝕩) nmc⍟⊣¨ "Left argument "⊸∾¨⟨"not allowed","required"⟩
      }𝕩
      𝕩 Then´⟜(⊏⟜bodies)˜⟜{!∘𝕩}¨ e
    } body

    {𝕊 parent:
      Inner Outer {parent˙ 𝕏 ⊢}¨ run
    }
  }¨ blockInfo

  program ← {
    consts⇐consts
    blocks⇐blocks
    names⇐0⊑2⊑token
  }
  
  (⊑blocks){𝔽} {program⇐program}
}
