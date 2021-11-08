*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/index.html).*

# BQN documentation

BQN's documentation describes what features it has, how to use them (with examples), and why they were chosen. For a linear introduction to the language, see the [tutorials](../tutorial/README.md). While the core language [specification](../spec/README.md) is complete, the documentation still has minor gaps.

Overview:
- [Syntax](syntax.md)
- [Types](types.md)
- [Primitives](primitive.md)
- [Paradigms](paradigms.md)

References:
- [Glossary](glossary.md)
- [BQN-Dyalog dictionary](fromDyalog.md)
- [BQN-J dictionary](fromJ.md)
- [BQN as combinatory logic](birds.md)

Concepts:
- [Context-free grammar](context.md)
- [Expression syntax](expression.md)
- [Arrays](array.md)
- [Based array theory](based.md)
- [Array notation and display](arrayrepr.md)
- [Array indices](indices.md)
- [Fill elements](fill.md)
- [The leading axis model](leading.md)
- [Function trains](train.md)
- [Blocks](block.md) (including function and modifier definition)
- [Lexical scoping](lexical.md)
- [Functional programming](functional.md)
- [Control flow](control.md)
- [Namespaces](namespace.md)
- [Object-oriented programming](oop.md)

Primitives:
- [Arithmetic](arithmetic.md) (`+-×÷⋆√⌊⌈|≤<>≥=≠`)
- [Array depth](depth.md) (`≡` and `⚇`)
- [Array dimensions](shape.md) (`≢=≠`)
- [Assert](assert.md) (`!`)
- [Deshape and Reshape](reshape.md) (`⥊`)
- [Enclose](enclose.md) (`<`)
- [Find](find.md) (`⍷`)
- [Fold and Insert](fold.md) (`´˝`)
- [Group](group.md) (`⊔`)
- [Identity functions](identity.md) (`⊢⊣`)
- [Indices and Replicate](replicate.md) (`/`)
- [Join and Join To](join.md) (`∾`)
- [Logical functions](logic.md) (`∧∨¬`)
- [Match](match.md) (`≡≢`)
- [Mapping](map.md) (`¨⌜`)
- [Ordering functions](order.md) (`∧∨⍋⍒`)
- [Pair](pair.md) (`⋈`)
- [Pick](pick.md) (`⊑`)
- [Prefixes and Suffixes](prefixes.md) (`↑↓`)
- [Range](range.md) (`↕`)
- [Repeat](repeat.md) (`⍟`)
- [Reverse and Rotate](reverse.md) (`⌽`)
- [Scan](scan.md) (`` ` ``)
- [Search functions](search.md) (`⊐⊒∊`)
- [Select](select.md) (`⊏`)
- [Self-search functions](selfcmp.md) (`⊐⊒∊⍷`)
- [Shift functions](shift.md) (`»«`)
- [Solo, Couple, and Merge](couple.md) (`≍>`)
- [Take and Drop](take.md) (`↑`)
- [Transpose](transpose.md) (`⍉`)
- [Undo](undo.md) (`⁼`)
- [Windows](windows.md) (`↕`)

Environment:
- [Embedded BQN](embed.md)
