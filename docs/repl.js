let body = document.body;
let doc={}; // html elements with a class
body.querySelectorAll('[class]').forEach(e=>doc[e.classList[0]]=e);
let setcount = !doc.count ? (s=>s) : (s=>{
  let l = Array.from(s).length;
  doc.count.textContent = l+" char"+(l!=1?"s":"");
});
let setExplain = e=>e;
let showErr = (s,e)=>{
  let r=e.src, w=e.message, loc=[];
  while (w.sh&&w.sh[0]===2) {
    let is; [is,w]=w;
    let n=is.sh?is.sh[0]:0, i=n?is[0]:is;
    let to=i=>s.slice(0,i).join('').split('\n');
    let ll=to(i), l=ll.length-1, j=ll[l].length, m=to()[l];
    let k=1,o=i-j,cl=j; while (k<n&&(cl=is[k]-o)<m.length) k++;
    let c=Array(cl).fill(0); c[j]=1;
    for (let h=1;h<k;h++) c[is[h]-o]=1;
    let add = ['',m,c.map(t=>t?'^':' ').join('')];
    loc = add.concat(k<n?['(and other lines)']:[], loc);
  }
  if (r==='!') w=w?fmt(w).replace(/^/gm,'! '):'! Error';
  else w=w.sh?w.join(''):w;
  doc.rslt.classList.add('err');
  doc.rslt.textContent=[w].concat(loc).join('\n');
}
let repl = ()=>{
  let s=Array.from(doc.code.value);
  doc.rslt.classList.remove('err');
  doc.rslt.textContent=' '; setExplain();
  setcount(s);
  setTimeout(() => {
    try {
      let src=str(s), c=compile(src,runtime);
      setExplain(src,c);
      doc.rslt.textContent=fmt(run.apply(null,c));
    } catch(e) {
      showErr(s,e);
    }
  }, 0);
}
if (doc.run) doc.run.onclick = repl;
let exp=0, explain;
if (doc.doexplain) doc.doexplain.onclick = () => {
  if (explain===undefined) {
    let drawEval = run(
      new Uint8Array([0,18,22,0,0,11,22,0,1,11,14,15,1,22,0,2,11,14,0,15,0,11,0,55,19,22,0,3,11,14,15,2,22,0,4,11,14,21,0,4,0,40,0,20,0,48,0,77,8,7,9,22,0,5,11,14,15,3,22,0,6,11,14,15,4,22,0,7,11,14,15,5,22,0,8,11,14,21,0,8,0,40,21,0,8,0,20,0,72,19,7,0,20,9,0,23,0,55,19,15,6,3,3,0,52,0,15,0,5,0,56,19,8,22,0,9,11,14,0,43,15,7,7,0,20,0,81,19,22,0,10,11,14,0,55,0,53,21,0,10,0,46,0,11,8,8,0,20,9,0,49,0,20,8,22,0,11,11,14,15,8,22,0,12,11,14,0,40,21,0,8,7,0,39,0,21,7,0,88,0,89,3,2,19,22,0,13,11,14,21,0,11,0,46,21,0,7,8,22,0,14,11,14,15,9,22,0,15,11,14,0,62,0,63,3,2,22,0,16,11,14,0,56,0,55,3,2,0,2,21,0,16,17,22,0,17,11,14,0,56,0,57,3,2,0,3,21,0,16,17,0,0,0,55,17,22,0,18,11,14,0,61,22,0,19,11,14,0,92,21,0,12,16,22,0,20,11,14,0,93,21,0,12,16,22,0,21,11,14,0,95,21,0,12,0,94,17,22,0,22,11,14,0,96,21,0,12,0,94,17,22,0,23,11,14,0,97,21,0,12,0,94,17,22,0,24,11,14,0,98,21,0,12,0,94,17,22,0,25,11,14,15,10,22,0,26,11,14,0,100,0,101,0,20,0,61,0,24,16,0,0,0,71,17,17,0,102,0,103,0,104,0,105,0,106,0,107,0,108,0,109,0,110,0,111,0,20,0,75,17,0,20,0,87,17,0,112,0,113,3,14,0,19,0,46,0,56,3,2,17,0,27,16,0,39,0,11,7,16,22,0,27,22,0,28,4,2,11,14,0,114,0,115,0,116,0,117,0,118,0,119,0,120,3,7,0,20,22,0,27,13,14,15,11,21,0,28,7,22,0,29,11,14,21,0,27,0,40,15,12,7,16,22,0,30,11,14,15,13,22,0,31,11,25,0,55,0,17,21,0,2,17,0,54,0,16,0,38,0,19,7,0,55,0,56,3,2,19,0,49,0,38,0,40,0,23,0,20,0,76,19,0,20,0,22,19,7,7,8,8,22,0,3,11,14,21,0,1,21,1,1,0,48,21,1,0,0,31,0,50,21,0,3,8,9,0,20,0,48,0,11,8,0,40,0,55,7,19,8,16,25,21,0,1,0,19,16,0,58,0,46,0,36,8,0,11,0,19,9,0,18,0,40,21,0,0,7,0,20,9,3,4,0,52,0,15,0,5,0,57,19,8,16,25,0,78,21,0,2,0,79,3,3,0,20,16,22,0,3,11,14,0,80,21,0,2,0,22,0,81,0,32,21,0,2,17,0,31,16,17,0,79,3,3,0,20,16,22,0,4,11,14,21,0,1,21,1,3,16,22,0,5,11,14,21,0,4,21,0,5,0,54,0,11,0,46,0,19,8,8,0,47,15,14,21,0,1,21,0,5,0,54,21,1,5,8,16,7,8,21,0,3,17,0,20,16,25,0,78,21,0,1,0,82,3,3,0,20,16,25,21,0,1,0,15,16,0,14,0,58,17,0,36,16,14,21,0,1,0,60,0,49,0,11,8,0,9,0,11,0,48,0,59,8,19,16,0,36,16,14,0,61,22,0,3,11,0,38,0,4,7,0,57,17,22,0,4,11,14,15,15,22,0,5,11,14,21,0,1,0,7,16,0,0,21,0,4,0,2,0,56,17,0,3,16,17,22,0,6,11,0,5,16,22,0,7,11,14,0,83,0,28,0,58,0,11,21,0,1,17,17,21,0,7,21,0,5,0,18,0,6,0,55,19,0,42,0,4,7,21,0,3,19,0,5,9,0,0,0,55,19,7,16,0,0,0,71,17,21,0,7,0,1,21,0,6,17,0,2,21,0,4,17,0,5,16,0,84,21,0,5,0,57,7,0,28,0,48,0,2,0,46,0,26,0,50,0,45,0,10,7,8,8,8,9,0,0,0,71,19,0,20,0,85,19,3,2,0,52,0,11,0,48,0,58,8,8,16,3,3,0,20,16,25,21,0,1,14,0,58,0,36,16,25,21,0,2,0,86,21,0,1,0,87,3,4,0,20,16,25,15,16,22,0,3,11,14,21,0,1,21,0,3,0,74,7,16,0,40,21,0,3,0,73,7,7,16,0,40,21,1,10,7,0,20,9,0,49,0,20,8,0,51,0,12,8,21,0,2,17,25,21,0,1,21,1,6,0,91,21,0,2,21,1,9,16,3,2,21,1,11,0,90,17,17,25,21,0,1,0,40,0,20,7,0,21,0,40,0,31,0,48,0,55,8,7,19,16,0,40,21,1,6,0,48,21,1,13,21,1,11,0,99,19,8,7,21,0,2,0,41,0,0,7,0,58,0,58,0,64,3,2,3,2,17,17,22,0,3,11,14,21,0,3,0,39,0,11,7,16,0,40,21,1,6,7,21,1,24,21,1,25,3,2,17,21,1,6,21,1,23,17,25,0,32,0,48,21,0,1,0,20,16,8,0,29,21,0,1,0,40,0,13,7,16,0,45,0,0,7,16,19,25,0,122,0,20,21,0,1,17,0,20,0,121,17,25,21,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,4,5,11,14,0,123,0,124,0,125,0,126,3,4,0,38,0,1,7,0,71,17,22,0,8,22,0,9,22,0,10,22,0,11,4,4,11,14,15,17,22,0,12,11,14,21,0,3,21,0,6,3,2,0,40,0,28,0,48,21,0,12,8,7,16,22,0,13,22,0,14,4,2,11,14,0,66,0,38,0,23,7,22,0,14,13,14,21,0,9,0,30,21,0,13,17,22,0,15,11,0,1,21,0,10,0,30,21,0,13,17,17,0,45,0,0,7,16,22,0,16,11,14,21,0,16,0,31,0,66,17,0,14,0,55,17,0,36,16,14,21,0,15,0,11,0,58,17,22,0,17,11,0,2,0,48,0,45,0,0,7,8,16,22,0,18,11,14,21,0,15,0,28,16,0,30,0,48,0,33,0,0,21,0,16,0,49,0,30,8,19,0,29,0,47,0,30,0,48,0,29,8,8,21,0,16,0,23,0,66,17,19,8,16,22,0,19,11,14,21,0,19,0,13,16,0,38,0,22,7,22,0,17,13,14,21,0,1,15,18,21,0,7,17,22,0,20,22,0,21,22,0,22,4,3,11,14,21,0,19,15,19,16,0,13,0,54,0,38,0,30,7,8,16,0,38,0,30,7,21,0,22,0,30,21,0,17,0,8,16,0,45,0,0,7,16,0,38,0,1,7,0,55,17,17,17,0,23,0,66,17,22,0,23,11,14,0,67,0,20,21,0,23,17,22,0,24,11,14,21,0,19,0,17,0,21,0,30,19,21,0,24,0,30,21,0,19,17,0,13,21,0,23,17,0,10,21,0,17,17,0,28,16,17,22,0,25,11,14,21,0,18,0,21,21,0,24,17,0,0,0,68,0,69,3,2,17,0,2,21,1,16,17,0,27,16,0,30,21,0,25,17,0,44,0,38,0,39,0,26,0,49,0,20,0,48,0,11,8,8,7,7,7,16,22,0,26,11,14,21,1,17,0,2,0,56,0,58,3,2,17,0,0,21,0,1,0,13,16,21,0,18,0,43,0,6,7,16,0,0,0,56,17,3,2,0,2,21,1,16,17,17,22,0,27,11,14,21,0,27,0,40,21,1,8,7,16,0,39,0,21,7,0,129,1,0,130,1,3,2,17,0,20,21,1,17,0,1,16,21,1,13,16,17,0,20,21,1,21,17,21,1,14,0,128,1,17,0,11,16,21,0,20,21,1,6,0,99,17,0,11,16,21,0,26,0,39,0,18,0,40,21,1,9,0,49,0,20,8,7,0,133,1,19,0,20,9,0,11,0,47,0,21,8,0,132,1,19,0,20,21,1,20,19,21,1,14,0,131,1,19,0,11,9,7,16,21,0,21,21,1,26,21,0,19,0,28,21,0,17,0,8,16,17,21,0,18,0,49,0,30,8,0,49,0,40,0,21,0,2,21,1,16,19,0,0,21,1,18,19,7,8,21,0,22,17,17,3,4,0,40,0,19,7,16,0,20,16,21,1,6,21,1,22,17,21,1,15,21,1,19,0,2,0,56,17,0,0,21,0,27,17,0,37,0,56,7,0,3,0,38,0,1,7,19,0,38,0,1,7,21,1,17,0,0,21,1,19,17,19,0,38,0,20,7,0,17,19,0,48,0,6,0,48,0,70,0,58,3,2,8,8,16,17,25,21,0,2,21,0,4,21,0,1,3,3,25,21,0,1,0,24,9,0,54,21,1,3,0,49,0,3,0,46,0,5,8,8,8,0,7,21,1,3,19,0,26,9,25,0,35,0,48,0,14,0,48,21,0,1,8,0,1,0,48,0,8,0,2,0,45,0,0,7,19,8,9,8,25,21,1,3,0,18,0,2,0,12,0,48,0,13,8,19,0,38,0,30,7,0,17,19,21,1,8,17,22,0,0,11,14,21,1,3,0,65,0,49,0,11,8,16,0,26,0,50,0,2,0,45,0,6,7,9,0,25,9,0,48,0,13,0,46,0,24,8,0,0,0,55,19,8,8,0,1,0,13,19,16,0,13,0,49,0,20,8,16,22,0,1,11,14,0,57,0,24,16,15,20,16,0,0,0,55,17,22,0,2,11,14,21,0,2,0,11,0,48,0,13,0,46,0,24,8,8,16,0,43,0,9,7,16,0,36,16,14,0,18,0,31,0,66,19,0,14,0,58,19,0,54,15,21,8,22,0,3,11,14,21,0,2,0,40,0,58,7,0,20,0,55,19,21,0,3,0,13,0,49,0,20,8,19,0,22,0,13,19,16,25,21,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,4,5,11,14,21,2,28,0,13,16,22,0,8,11,14,21,0,1,0,30,21,0,6,17,21,2,29,16,0,14,0,48,21,0,8,8,0,2,0,1,19,0,0,0,18,19,21,0,4,0,0,0,57,17,0,0,21,0,8,17,17,0,38,0,30,7,21,2,30,17,22,0,9,11,14,21,0,7,0,40,0,127,7,16,22,0,10,11,14,21,0,9,0,20,21,0,10,17,22,0,11,11,14,21,0,11,0,20,16,0,20,21,0,1,17,0,30,0,48,0,29,8,0,55,0,1,21,0,6,17,0,20,21,0,7,17,0,28,21,0,11,0,40,0,13,7,16,17,0,20,21,0,1,0,13,16,0,24,16,17,17,22,0,12,11,14,21,0,9,21,0,6,0,40,0,8,0,46,0,24,8,0,0,0,18,19,0,38,0,30,7,21,0,1,19,7,21,0,7,17,21,0,10,3,3,0,12,16,0,27,16,0,39,0,11,7,16,22,0,13,11,14,21,1,14,0,28,21,1,17,0,8,16,17,0,32,21,0,6,17,22,0,14,11,14,21,0,12,21,0,13,0,30,21,0,14,17,0,56,0,3,21,0,7,0,0,21,0,6,17,17,0,30,21,0,14,17,3,3,25,21,0,1,0,29,16,22,0,3,11,0,38,0,30,7,21,0,1,17,22,0,4,11,14,21,1,13,0,13,16,0,24,16,0,30,0,48,21,0,4,0,34,16,8,0,50,21,1,11,0,30,21,1,13,17,0,30,21,0,4,17,0,14,21,0,4,0,33,16,17,0,38,0,28,7,21,0,3,17,8,16,25,21,1,0,0,13,16,0,24,16,21,0,1,0,54,21,1,1,0,49,0,30,8,8,16,0,12,16,0,2,0,46,0,44,0,0,7,8,21,1,0,0,41,0,14,7,21,0,1,17,17,25,21,0,1,0,30,0,48,21,0,2,0,28,21,0,1,17,8,0,50,0,40,0,55,7,8,16,21,1,3,21,0,2,0,38,0,30,7,16,17,25])
     ,[runtime[0],runtime[1],runtime[2],runtime[3],runtime[4],runtime[6],runtime[7],runtime[8],runtime[9],runtime[10],runtime[11],runtime[12],runtime[13],runtime[14],runtime[15],runtime[18],runtime[19],runtime[20],runtime[21],runtime[22],runtime[23],runtime[24],runtime[25],runtime[26],runtime[27],runtime[29],runtime[30],runtime[31],runtime[32],runtime[33],runtime[35],runtime[36],runtime[37],runtime[38],runtime[40],runtime[41],runtime[42],runtime[43],runtime[44],runtime[45],runtime[46],runtime[47],runtime[48],runtime[49],runtime[50],runtime[51],runtime[52],runtime[53],runtime[54],runtime[55],runtime[56],runtime[57],runtime[58],runtime[59],runtime[61],1,2,3,0,-Infinity,Infinity,10,10.75,24,-2,128,-1,-1.25,0.6,0.1,512,'0',' ','=','|','\"',str("t"),str("  "),str("<"),str(">"),str("</"),str(" "),str("/>"),str("-"),str(""),str("."),str("=\'"),str("\'"),str("x"),str("y"),str("svg"),str("viewBox"),str("class=Paren|stroke=currentColor|fill=none|stroke-width=1"),str("class=code|stroke-width=1|rx=10"),str("g"),str("font-family=BQN,monospace|font-size=18px"),str("text-anchor=middle"),str("class=codeCover|stroke-width=6|stroke-linejoin=round"),str("font-size=15px|opacity=0.9"),str("text"),str("Number"),str("¯.π∞"),str("Paren"),str("()"),str("Bracket"),str("⟨⟩"),str("Brace"),str("{}"),str("Nothing"),str("·"),str("String"),str("@"),str("Comment"),str("#"),str("Gets"),str("Ligature"),str("Separator"),str("Value"),str("Function"),str("Modifier"),str("Modifier2"),str("<tspan class=\'"),str("\'>"),str("11111000000000010000022000"),str("000//232323223102303200121"),str("11111111111111011101111111"),str("00000110111001001101000100"),str("</tspan>"),str("rect"),str("width"),str("height"),str("path"),str("d"),str("MVH")]
     ,[[0,1,0,32],[0,0,484,4],[0,0,571,3],[0,0,614,6],[0,0,717,3],[0,0,730,8],[0,0,954,3],[0,0,964,3],[0,0,980,4],[0,0,1031,3],[0,0,1056,4],[1,1,1153,2],[0,0,1183,3],[0,0,1197,28],[1,0,1950,5],[1,1,1962,2],[1,1,1994,2],[0,1,2024,4],[0,0,2214,15],[0,0,2512,5],[0,0,2594,3],[0,0,2645,3]]
    );
    explain = (s,c) => {
      doc.explain.innerHTML = s?drawEval(s,c).map(l=>l.join("")).join("\n"):'';
    }
  }
  explain(); // Clear
  setExplain = doc.doexplain.classList.toggle('selected')
             ? explain : (e=>e);
}

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
  } else if (ev.key=='\\') {
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

let syncls={ v:"Value", f:"Function", m:"Modifier", d:"Modifier2", n:"Number", g:"Gets", p:"Paren", b:"Bracket", k:"Brace", l:"Ligature", n:"Nothing", s:"Separator", c:"Comment", a:"String" };
let keydesc='f+Conjugate;Add_f-Negate;Subtract_f×Sign;Multiply_f÷Reciprocal;Divide_f⋆Exponential;Power_f√Square Root;Root_f⌊Floor;Minimum_f⌈Ceiling;Maximum_f∧Sort Up;And_f∨Sort Down;Or_f¬Not;Span_f|Absolute Value;Modulus_f≤Less Than or Equal to_f<Enclose;Less Than_f>Merge;Greater Than_f≥Greater Than or Equal to_f=Rank;Equals_f≠Length;Not Equals_f≡Depth;Match_f≢Shape;Not Match_f⊣Identity;Left_f⊢Identity;Right_f⥊Deshape;Reshape_f∾Join;Join to_f≍Solo;Couple_f↑Prefixes;Take_f↓Suffixes;Drop_f↕Range;Windows_f«Shift Before_f»Shift After_f⌽Reverse;Rotate_f⍉Transpose;Reorder axes_f/Indices;Replicate_f⍋Grade Up;Bins Up_f⍒Grade Down;Bins Down_f⊏First Cell;Select_f⊑First;Pick_f⊐Index of_f⊒Occurrence Count;Progressive Index of_f∊Unique Mask;Member of_f⍷Deduplicate;Find_f⊔Group Indices;Group_f!Assert;Assert with message_m˙Constant_m˜Self/Swap_d∘Atop_d○Over_d⊸Before/Bind_d⟜After/Bind_d⌾Under_d⊘Valences_d◶Choose_d⎉Rank_m˘Cells_d⚇Depth_m¨Each_m⌜Table_d⍟Repeat_m⁼Undo_m´Fold_m˝Insert_m`Scan_g←Define_g⇐Export_g↩Change_g→Return_s⋄Separator_s,Separator_p(Begin expression_p)End expression_k{Begin block_k}End block_b⟨Begin list_b⟩End list_l‿Strand_n·Nothing_v•System_v𝕨Left argument_f𝕎Left argument (as function)_v𝕩Right argument_f𝕏Right argument (as function)_v𝕗Modifier left operand (as subject)_f𝔽Modifier left operand_v𝕘2-modifier right operand (as subject)_f𝔾2-modifier right operand_v𝕤Current function (as subject)_f𝕊Current function_m𝕣Current modifier_n¯Minus_nπPi_n∞Infinity_a@Null character_c#Comment'.split(/[\n_]/);
let kk=Array.from('`123456890-=~!@#$%^&*()_+qwertuiop[]QWERTIOP{}asdfghjkl;ASFGHKL:"zxcvbm,./XVBM<>? \'');
let kv=Array.from('˜˘¨⁼⌜´˝∞¯•÷×¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆⌽𝕨∊↑∧⊔⊏⊐π←→↙𝕎⍷𝕣⍋⊑⊒⍳⊣⊢⍉𝕤↕𝕗𝕘⊸∘○⟜⋄↖𝕊𝔽𝔾«⌾»·˙⥊𝕩↓∨⌊≡∾≍≠𝕏⍒⌈≢≤≥⇐‿↩');
let keys={}, revkeys={};
kk.map((k,i)=>{keys[k]=kv[i];revkeys[kv[i]]=k;});
doc.kb.innerHTML = keydesc.map(d=>{
  let s = syncls[d[0]];
  let c = Array.from(d)[1];
  let t = d.slice(1+c.length).replace(';','\n');
  let k = revkeys[c]; if (k) t += '\n\\ '+(k==='"'?'&quot;':k);
  return '<span title="'+t+'" class="'+s+'">'+c+'</span>'
}).join("&#8203;"); // zero-width space
doc.kb.onmousedown = ev => {
  let t = ev.target;
  if (t.nodeName === 'SPAN') {
    return typeChar(doc.code, t.textContent, ev);
  }
}

if (doc.perm) doc.perm.onmouseover = doc.perm.onfocus = () => {
  let b=(new TextEncoder()).encode(doc.code.value);
  doc.perm.href='#code='+btoa(String.fromCharCode(...b));
}

let demo = 0;
if (doc.demo) doc.demo.onclick = () => {
  const demos = [
    '<⟜\'a\'⊸/ "Big Questions Notation"'
   ,'≠⌜˜ 8 ⥊ 0‿1'
   ,'+´ 1 + ↕100'
   ,'(+´ ÷ ≠) 2‿5‿7‿4'
   ,'+`-˝ "()" =⌜ "(2×(4-1)÷(√9))"'
   ,'(⊑ + ↕∘¬˜´) "CG"'
   ,'0‿1‿10‿100⊸⍋⊸⊔ ⟨6,11,9,20,105,1,¯1,4⟩'
   ,'{(+`𝕩<\'a\') ⊔ 𝕩} "camelCaseWord"'
   ,'3‿4‿2⌾(0‿0⊸⍉) 3‿3⥊¯1'
   ,'∾ (<˘ ≍¨¨ 1↓↓) "abcd"'
   ,'Life←{∨´1‿𝕩∧3‿4=+˝⥊⌽⟜𝕩¨∾⌜˜¯1‿0‿1}\nLife⍟(↕4) 6‿6↑(1⊸=∨5⊸≤)3‿3⥊↕9'
   ,'⥊ 1‿0‿1 ∧⌜⍟3 1'
   ,'⌈˝ (≠ ↕ 0‿0⊸∾) 1‿2‿5‿4‿0‿2‿1'
  ];
  ++demo; if (demo===demos.length) demo=0;
  doc.code.value = demos[demo]; repl();
}

if (location.hash) {
  let code='', run=1;
  location.hash.slice(1).split('&').map(s => {
    if (s.slice(0,5)==='code=') code=s.slice(5);
    if (s.slice(0,3)==='norun') run=0;
  });
  let b=atob(code);
  b=new Uint8Array([...b].map(c=>c.charCodeAt(0)));
  setcount(doc.code.value = (new TextDecoder()).decode(b));
  if (run) repl();
}
doc.code.focus();
