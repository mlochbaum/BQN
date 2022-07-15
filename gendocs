#! /usr/bin/env bqn

# Generate HTML files from markdown ones
At‿List‿Type ← •file
files ← {
  # •args gives a list of files, but if it's empty, convert everything
  0<≠•args ? (('/'=⊑)⊸↓•path∾⁼•wdpath⊸At)¨ •args
;
  # All markdown files in directories corresponding to ones in docs/
  SubDirs ← { 𝕩 <⊸∾ ∾ 𝕊¨ ('d'=Type¨)⊸/ 𝕩⊸At¨ List 𝕩 }
  ∾ (<At¨·(".md"≡¯3⊸↑)¨⊸/List)¨ (≠↓¨SubDirs) "docs/"
}
files •Import "md.bqn"
