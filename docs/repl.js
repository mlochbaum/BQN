let body = document.body;
let doc={}; // html elements with a class
body.querySelectorAll('[class]').forEach(e=>doc[e.classList[0]]=e);
let repl = ()=>{
  try {
    let s=doc.code.value;
    doc.rslt.classList.remove('err');
    doc.rslt.textContent=fmt(bqn(s));
  } catch(e) {
  //if (console&&console.error) console.error(e.stack);
    doc.rslt.classList.add('err');
    doc.rslt.textContent=e;
  }
}
doc.run.onclick = repl;

let keymode=0; // 1 for backslash
doc.code.onkeydown = ev => {
  let k = ev.which;
  if (16<=k && k<=20) {
    return;
  } if (k==13 && (ev.shiftKey||ev.ctrlKey||ev.altKey||ev.metaKey)) { // *-enter
    repl(); return false;
  } if (keymode) {
    keymode = 0;
    doc.kb.classList.remove('backslash');
    let c = keys[ev.key];
    if (c) return typeChar(ev.target, c, ev);
  } else if (k===220) { // \
    keymode = 1;
    doc.kb.classList.add('backslash');
    ev.preventDefault();
  }
}
let typeChar = (t, c, ev) => {
  ev.preventDefault();
  let v = t.value;
  let i = t.selectionStart;
  t.value = v.slice(0,i)+c+v.slice(t.selectionEnd);
  t.selectionStart = t.selectionEnd = i+c.length;
  return false;
}

let syncls={ v:"Value", f:"Function", m:"Modifier", d:"Modifier2", n:"Number", g:"Gets", p:"Paren", b:"Bracket", k:"Brace", l:"Ligature", n:"Nothing", s:"Separator", c:"Comment" };
let keydesc='f+Conjugate;Add_f-Negate;Subtract_f×Sign;Multiply_f÷Reciprocal;Divide_f⋆Exponential;Power_f√Square Root;Root_f⌊Floor;Minimum_f⌈Ceiling;Maximum_f∧Sort Up;And_f∨Sort Down;Or_f¬Not;Span_f|Absolute Value;Modulus_f≤Less Than or Equal to_f<Enclose;Less Than_f>Merge;Greater Than_f≥Greater Than or Equal to_f=Rank;Equals_f≠Length;Not Equals_f≡Depth;Match_f≢Shape;Not Match_f⊣Identity;Left_f⊢Identity;Right_f⥊Deshape;Reshape_f∾Join;Join to_f≍Solo;Couple_f↑Prefixes;Take_f↓Suffixes;Drop_f↕Range;Windows_f⌽Reverse;Rotate_f⍉Transpose;Reorder axes_f/Indices;Replicate_f⍋Grade Up;Bins Up_f⍒Grade Down;Bins Down_f⊏First Cell;Select_f⊑First;Pick_f⊐Index of_f⊒Occurrence Count;Progressive Index of_f∊Unique Mask;Member of_f⍷Deduplicate;Find_f⊔Group Indices;Group_f!Assert;Assert with message_m˜Self/Swap_d∘Atop_d○Over_d⊸Before/Bind_d⟜After/Bind_d⌾Under_d⊘Valences_d◶Choose_d⎉Rank_m˘Cells_d⚇Depth_m¨Each_m⌜Table_d⍟Repeat_m⁼Undo_m´Fold_m˝Insert_m`Scan_b←Define_b↩Change_b→Return_s⋄Separator_s,Separator_p(Begin expression_p)End expression_k{Begin block_k}End block_b⟨Begin list_b⟩End list_l‿Strand_n·Nothing_v•System_v𝕨Left argument_f𝕎Left argument (as function)_v𝕩Right argument_f𝕏Right argument (as function)_v𝕗Modifier left operand (as subject)_f𝔽Modifier left operand_v𝕘2-modifier right operand (as subject)_f𝔾2-modifier right operand_v𝕤Current function (as subject)_f𝕊Current function_m𝕣Current modifier_n¯Minus_nπPi_n∞Infinity_c#Comment'.split(/[\n_]/);
let kk=Array.from('`123456890-=~!@#$%^&*()_+qwertuiop[]QWERTIOP{}asdfghjkl;ASFGK:"zxcvbm,./XVBM<> \'');
let kv=Array.from('˜˘¨⁼⌜´˝∞¯•÷×¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆⌽𝕨∊↑∧⊔⊏⊐π←→↙𝕎⍷𝕣⍋⊑⊒⍳⊣⊢⍉𝕤↕𝕗𝕘⊸∘○⟜⋄↖𝕊𝔽𝔾⌾·˙⥊𝕩↓∨⌊≡∾≍≠𝕏⍒⌈≢≤≥‿↩');
let keys={}, revkeys={};
kk.map((k,i)=>{keys[k]=kv[i];revkeys[kv[i]]=k;});
doc.kb.innerHTML = keydesc.map(d=>{
  let s = syncls[d[0]];
  let c = Array.from(d)[1];
  let t = d.slice(1+c.length).replace(';','\n');
  let k = revkeys[c]; if (k) t += '\n\\ '+k;
  return '<span title="'+t+'" class="'+s+'">'+c+'</span>'
}).join("&#8203;"); // zero-width space
doc.kb.onmousedown = ev => {
  let t = ev.target;
  if (t.nodeName === 'SPAN') {
    return typeChar(doc.code, t.textContent, ev);
  }
}

doc.perm.onmouseover = doc.perm.onfocus = () => {
  doc.perm.href='#code='+escape(doc.code.value)
}

if (location.hash) {
  let hp={};
  location.hash.substring(1).split(',').map(s=>{
    let[k,v]=s.split('=');hp[k]=unescape(v)
  });
  doc.code.value = hp.code||'';
  if (hp.run) repl();
}
doc.code.focus();
