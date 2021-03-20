let body = document.body;
let doc={}; // html elements with a class
body.querySelectorAll('[class]').forEach(e=>doc[e.classList[0]]=e);

let setcount = s=>s;
if (doc.count) {
  let count_activeMin;
  setcount = (s,m) => {
    let l = Array.from(s).length;
    if (l<m && m!==count_activeMin) return;
    count_activeMin = m;
    doc.count.textContent = l<m ? "" : l+" char"+(l!=1?"s":"");
  }
  let c = doc.code;
  c.onmouseup = c.onkeyup = () => {
    let s=c.selectionStart, e=c.selectionEnd;
    setcount(c.value.slice(s,e), 2);
  }
}

let setExplain = e=>e;
let repl = ()=>{
  let s=Array.from(doc.code.value), src=str(s);
  doc.rslt.classList.remove('err');
  doc.rslt.textContent=' '; setExplain();
  setcount(s);
  setTimeout(() => {
    try {
      let c=compile(src,runtime);
      setExplain(src,c);
      doc.rslt.textContent=fmt(run.apply(null,c));
    } catch(e) {
      doc.rslt.classList.add('err');
      doc.rslt.textContent=fmtErr(src,e);
    }
  }, 0);
}
if (doc.run) doc.run.onclick = repl;
let exp=0, explain;
if (doc.doexplain) doc.doexplain.onclick = () => {
  if (explain===undefined) {
    let drawEval = run(
      [0,19,22,0,0,11,22,0,1,11,14,15,1,22,0,2,11,14,15,2,22,0,3,11,14,15,3,22,0,4,11,14,15,4,22,0,5,11,14,0,20,0,46,21,0,5,8,0,31,9,0,20,0,50,21,0,5,8,15,5,3,3,0,52,0,16,0,5,0,56,19,8,22,0,6,11,14,21,0,6,21,0,6,0,41,0,21,7,0,69,19,0,21,9,0,24,0,55,19,15,6,3,3,0,52,0,16,0,5,0,56,19,8,22,0,7,11,14,0,43,15,7,7,0,21,0,82,19,22,0,8,11,14,0,55,0,53,21,0,8,0,46,0,11,8,8,0,21,9,0,49,0,21,8,22,0,9,11,14,15,8,22,0,10,11,14,21,0,6,0,40,0,22,7,0,85,0,86,3,2,19,22,0,11,11,14,21,0,9,0,46,21,0,4,8,22,0,12,11,14,15,9,22,0,13,11,14,0,63,0,64,3,2,22,0,14,11,14,0,56,0,55,3,2,0,2,21,0,14,17,22,0,15,11,14,0,56,0,57,3,2,0,3,21,0,14,17,0,0,0,58,0,65,3,2,17,22,0,16,11,14,0,61,22,0,17,11,14,0,89,21,0,10,16,22,0,18,11,14,0,90,21,0,10,16,22,0,19,11,14,0,92,21,0,10,0,91,17,22,0,20,11,14,0,93,21,0,10,0,91,17,22,0,21,11,14,0,94,21,0,10,0,91,17,22,0,22,11,14,0,95,21,0,10,0,91,17,22,0,23,11,14,0,96,0,97,0,21,0,61,0,25,16,0,0,0,70,17,17,0,98,0,99,0,100,0,101,0,102,0,103,0,104,0,105,0,106,0,107,0,21,0,73,17,0,21,0,84,17,0,108,0,109,3,14,0,20,0,46,0,56,3,2,17,0,27,16,0,40,0,11,7,16,22,0,24,22,0,25,4,2,11,14,0,110,0,111,0,112,0,113,0,114,0,115,0,116,3,7,0,21,22,0,24,13,14,15,10,21,0,25,7,22,0,26,11,14,21,0,24,0,41,15,11,7,16,22,0,27,11,14,0,119,22,0,28,11,14,0,122,0,123,0,124,0,125,3,4,0,41,0,121,0,49,0,21,8,0,21,0,120,19,7,16,22,0,29,11,14,15,12,22,0,30,11,25,0,55,0,18,21,0,2,17,0,54,0,17,0,39,0,20,7,0,55,0,56,3,2,19,0,49,0,39,0,41,0,24,0,21,0,75,19,0,21,0,23,19,7,7,8,8,22,0,3,11,14,21,0,1,21,1,1,0,48,21,1,0,0,31,0,50,21,0,3,8,9,0,21,0,48,0,11,8,0,41,0,55,7,19,8,16,25,15,13,22,0,3,11,14,0,76,21,0,2,0,77,3,3,0,21,16,22,0,4,11,14,0,78,21,0,2,0,28,0,69,0,13,21,0,2,17,0,45,0,9,7,16,17,0,77,3,3,0,21,16,22,0,5,11,14,21,0,1,0,16,16,22,0,6,11,0,11,0,55,17,22,0,7,11,14,21,0,5,21,0,7,0,54,0,11,0,46,0,20,8,8,0,47,15,14,21,0,1,21,0,7,0,54,15,15,8,16,7,8,21,0,4,17,0,21,16,25,0,76,21,0,1,0,80,3,3,0,21,16,25,21,0,1,0,60,0,49,0,11,8,0,9,0,11,0,48,0,59,8,19,16,0,43,0,9,7,16,0,37,16,14,0,61,22,0,3,11,0,39,0,4,7,0,57,17,22,0,4,11,14,0,70,0,1,0,81,17,22,0,5,22,0,6,4,2,11,14,0,58,0,11,21,0,1,17,22,0,7,11,14,21,0,1,0,7,16,22,0,8,11,14,21,0,8,0,2,21,0,4,17,0,0,0,62,17,0,5,16,22,0,9,11,14,21,0,7,0,28,16,0,41,21,0,5,7,0,49,0,11,0,47,0,22,8,8,16,0,22,16,21,0,4,0,3,21,0,9,17,0,5,16,15,16,0,48,0,13,0,46,0,25,8,8,16,21,0,9,15,17,0,48,0,13,0,46,0,25,8,8,16,0,13,0,11,0,58,19,0,54,0,21,0,48,0,30,0,46,0,26,0,31,9,0,50,0,41,21,0,6,7,8,8,8,8,16,3,3,0,21,16,0,27,16,0,40,0,21,0,46,0,11,8,7,16,0,43,0,0,0,48,0,70,8,0,49,0,36,8,7,16,25,21,0,1,14,0,58,0,37,16,25,21,0,1,14,0,58,0,37,16,25,21,0,2,0,83,21,0,1,0,84,3,4,0,21,16,25,15,18,22,0,3,11,14,21,0,1,21,0,3,0,72,7,16,0,41,21,0,3,0,71,7,7,16,0,41,21,1,8,7,0,21,9,0,49,0,21,8,0,51,0,12,8,21,0,2,17,25,21,0,1,21,1,3,0,88,21,0,2,21,1,7,16,3,2,21,1,9,0,87,17,17,25,0,32,0,48,21,0,1,0,21,16,8,0,29,21,0,1,0,41,0,13,7,16,0,45,0,0,7,16,19,25,0,118,0,21,21,0,1,17,0,21,0,117,17,25,21,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,4,2,22,0,8,4,5,11,14,0,126,0,127,0,128,0,129,3,4,0,39,0,1,7,0,70,17,22,0,9,22,0,10,22,0,11,22,0,12,4,4,11,14,15,19,22,0,13,11,14,21,0,3,21,0,6,3,2,0,41,0,28,0,48,21,0,13,8,7,16,0,41,0,24,7,0,58,0,65,3,2,17,22,0,14,22,0,15,4,2,11,14,21,0,10,0,30,21,0,14,17,22,0,16,11,0,14,0,65,17,22,0,17,11,14,21,0,13,0,28,16,0,39,0,28,0,48,21,0,17,8,0,50,0,18,0,0,0,55,19,0,39,0,30,7,21,0,3,19,8,7,22,0,16,13,14,21,0,11,0,30,21,0,14,17,0,31,0,48,0,65,8,0,50,0,55,8,16,22,0,18,11,14,21,0,16,0,1,21,0,18,17,0,45,0,0,7,16,22,0,19,11,14,21,0,19,0,31,0,65,17,0,14,0,55,17,0,37,16,14,21,0,16,0,11,0,58,17,22,0,20,11,0,2,0,48,0,2,0,48,21,0,18,8,0,45,0,0,7,9,8,16,22,0,21,11,14,21,0,18,0,8,21,0,16,17,0,28,16,0,30,0,48,0,33,0,0,21,0,19,0,49,0,30,8,19,0,29,0,47,0,30,0,48,0,29,8,8,21,0,19,0,24,0,65,17,19,8,16,22,0,22,11,14,21,0,20,0,8,16,0,23,0,48,0,13,8,21,0,22,17,22,0,23,11,14,21,0,1,15,20,21,0,8,17,22,0,24,22,0,25,22,0,26,4,3,11,14,21,0,22,15,21,16,0,13,0,54,0,39,0,30,7,8,16,0,39,0,30,7,21,0,26,0,30,21,0,23,0,45,0,0,7,16,0,39,0,1,7,0,55,17,17,17,0,24,0,65,17,22,0,27,11,14,0,66,0,21,21,0,27,17,22,0,28,11,14,21,0,22,0,18,0,22,0,30,19,21,0,17,0,1,21,0,28,17,0,30,21,0,22,17,0,13,21,0,27,17,0,15,21,0,23,17,0,28,16,17,22,0,29,11,14,21,0,21,0,22,21,0,28,17,0,0,0,62,0,67,3,2,17,0,2,21,1,14,17,0,27,16,21,1,6,16,0,30,21,0,29,17,0,44,0,39,0,40,0,26,0,49,0,21,8,0,41,0,21,7,0,132,19,0,21,9,0,46,0,11,8,7,7,7,16,22,0,30,11,14,21,0,21,0,30,21,0,22,0,28,21,0,23,17,17,0,41,0,22,0,2,21,1,14,19,0,0,21,1,16,19,0,46,21,1,11,21,1,9,0,133,19,8,7,21,0,26,17,22,0,31,11,14,21,1,15,0,2,0,56,0,58,3,2,17,0,0,21,0,1,0,13,16,21,0,21,0,43,0,6,7,16,0,0,0,56,17,3,2,0,2,21,1,14,17,17,22,0,32,11,14,21,0,32,21,1,6,16,0,40,0,22,7,0,135,0,136,3,2,17,0,21,21,1,15,0,1,16,21,1,11,16,17,0,21,21,1,19,17,21,1,12,0,134,17,0,11,16,21,0,24,21,1,3,0,133,17,0,11,16,21,0,30,0,41,0,19,0,11,0,47,0,22,8,0,138,19,0,21,21,1,18,19,21,1,12,0,137,19,7,16,21,0,25,0,41,0,21,7,0,19,0,41,21,1,3,7,21,0,31,19,0,47,0,11,0,47,0,22,8,8,0,41,0,31,0,48,0,55,8,7,19,16,0,41,21,1,3,7,21,1,22,21,1,23,3,2,17,21,1,3,21,1,21,17,3,4,0,41,0,20,7,16,0,21,16,21,1,3,21,1,20,17,21,1,13,21,1,17,0,2,0,56,17,0,0,21,0,32,17,0,38,0,56,7,0,3,0,39,0,1,7,19,0,39,0,1,7,21,1,15,0,0,21,1,17,17,19,0,39,0,21,7,0,18,19,0,48,0,6,0,48,0,68,0,58,3,2,8,8,16,17,25,21,0,1,0,20,16,0,58,0,46,0,37,8,0,11,0,20,9,0,19,0,41,21,0,0,7,0,21,9,3,4,0,52,0,16,0,5,0,57,19,8,16,25,21,0,2,21,0,4,21,0,1,3,3,25,21,0,1,0,20,16,21,1,6,0,15,0,57,17,0,54,0,41,21,1,3,7,0,21,9,8,16,0,41,0,21,0,48,0,79,8,7,16,25,21,0,1,0,15,21,1,3,17,22,0,3,11,14,21,0,2,21,0,1,3,2,0,22,0,26,0,31,9,0,50,0,7,0,48,21,1,3,8,8,0,21,0,43,0,28,0,48,21,0,3,8,0,47,21,1,3,0,49,0,3,8,0,5,9,0,49,21,0,0,8,8,7,19,3,2,0,52,21,0,3,0,43,0,10,7,16,8,16,25,21,0,1,0,7,21,1,4,17,22,0,1,12,0,2,16,22,0,3,11,14,21,0,1,0,58,0,56,3,2,0,25,16,0,28,0,48,21,0,3,8,0,47,0,2,0,48,21,1,3,8,0,49,21,0,0,0,21,21,1,4,0,49,0,3,8,0,5,9,0,49,0,11,0,47,0,22,8,8,19,8,8,3,2,0,52,21,0,3,0,43,0,10,7,16,8,21,0,2,17,25,0,36,0,48,0,14,0,48,21,0,1,8,0,1,0,48,0,8,0,2,0,45,0,0,7,19,8,9,8,25,21,1,3,0,19,0,2,0,12,0,48,0,13,8,19,0,39,0,30,7,0,18,19,21,1,9,17,0,0,0,55,17,0,0,21,1,3,0,13,16,0,25,16,17,22,0,0,11,14,0,19,0,31,0,65,19,0,14,0,58,19,0,54,15,22,8,22,0,1,11,14,21,0,0,0,41,0,58,7,0,21,0,55,19,21,0,1,0,13,0,49,0,21,8,19,0,23,0,13,19,16,25,21,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,4,5,11,14,21,2,25,0,13,16,22,0,8,11,14,21,0,1,0,30,21,0,6,17,21,2,26,16,0,14,0,48,21,0,8,8,0,2,0,1,19,0,0,0,19,19,21,0,4,0,0,0,57,17,0,0,21,0,8,17,17,0,39,0,30,7,21,2,27,17,22,0,9,11,14,21,0,7,0,41,0,130,7,16,22,0,10,11,14,21,0,9,0,21,21,0,10,17,22,0,11,11,14,0,61,0,0,0,74,17,0,14,21,0,1,17,0,28,16,22,0,12,11,14,21,0,1,0,30,0,48,21,0,12,8,0,50,0,131,0,30,21,0,6,0,34,21,0,12,17,17,8,16,22,0,1,12,14,21,0,1,0,32,21,2,28,17,22,0,13,11,0,12,0,48,0,13,8,21,2,28,17,22,0,14,11,0,8,16,0,28,16,22,0,15,11,14,21,0,13,0,28,21,0,14,17,0,39,0,30,7,21,2,29,17,0,39,0,21,7,22,0,11,13,14,0,55,0,1,21,0,6,17,0,21,21,0,7,17,0,21,21,0,14,0,28,16,17,0,28,21,0,11,0,41,0,13,7,16,17,0,21,21,0,15,17,0,29,16,22,0,16,11,14,21,0,11,0,21,16,0,21,21,0,1,0,30,21,0,15,17,17,0,30,21,0,16,17,22,0,17,11,14,0,55,0,21,21,2,29,0,41,0,13,7,16,17,0,30,21,0,13,17,22,0,18,11,14,21,0,17,0,28,0,48,0,13,0,46,0,25,8,0,12,21,0,18,0,43,0,0,7,16,19,0,30,21,0,16,19,8,16,22,0,19,11,14,21,0,9,21,0,7,0,0,0,55,17,0,42,0,28,7,0,23,21,0,1,0,13,16,19,0,45,0,0,7,9,0,47,0,12,0,2,0,18,19,8,21,0,6,17,0,39,0,1,7,0,55,17,0,28,21,0,18,17,0,39,0,36,7,21,0,19,17,21,0,10,3,3,0,12,16,0,27,16,0,40,0,11,7,16,22,0,20,11,14,21,1,15,0,28,21,1,23,17,0,32,21,0,6,17,22,0,21,11,14,21,0,17,21,0,20,0,30,21,0,21,17,0,56,0,3,21,0,7,0,0,21,0,6,17,17,0,30,21,0,21,17,3,3,25,21,0,1,0,29,16,22,0,3,11,0,39,0,30,7,21,0,1,17,22,0,4,11,14,21,1,14,0,13,16,0,25,16,0,30,0,48,21,0,4,0,35,16,8,0,50,21,1,12,0,30,21,1,14,17,0,30,21,0,4,17,0,14,21,0,4,0,33,16,17,0,39,0,28,7,21,0,3,17,8,16,25,21,0,1,0,30,0,48,21,0,2,0,28,21,0,1,17,8,0,50,0,41,0,55,7,8,16,21,1,1,21,0,2,0,39,0,30,7,16,17,25]
     ,[runtime[0],runtime[1],runtime[2],runtime[3],runtime[4],runtime[6],runtime[7],runtime[8],runtime[9],runtime[10],runtime[11],runtime[12],runtime[13],runtime[14],runtime[15],runtime[16],runtime[18],runtime[19],runtime[20],runtime[21],runtime[22],runtime[23],runtime[24],runtime[25],runtime[26],runtime[27],runtime[30],runtime[31],runtime[32],runtime[33],runtime[35],runtime[36],runtime[37],runtime[38],runtime[39],runtime[40],runtime[41],runtime[42],runtime[43],runtime[44],runtime[45],runtime[46],runtime[48],runtime[49],runtime[50],runtime[51],runtime[52],runtime[53],runtime[54],runtime[55],runtime[56],runtime[57],runtime[58],runtime[59],runtime[61],1,2,3,0,-Infinity,Infinity,10,0.5,10.84,24,-1,-1.25,0.1,512,' ','0','=','|','\"',' ',str("t"),str("<"),str(">"),str("</"),str("  "),str("/>"),str("-."),str(" "),str("=\'"),str("\'"),str("x"),str("y"),str("svg"),str("viewBox"),str("stroke=currentColor|fill=none|stroke-width=1"),str("class=code|stroke-width=1|rx=10"),str("g"),str("font-family=BQN,monospace|font-size=18px|class=Paren|fill=currentColor"),str("font-size=15px|text-anchor=middle"),str("class=codeCover|stroke-width=8|stroke-linejoin=round"),str("opacity=0.9"),str("Number"),str("¯.π∞"),str("Paren"),str("()"),str("Bracket"),str("⟨⟩"),str("Brace"),str("{}"),str("Nothing"),str("·"),str("String"),str("@"),str("Comment"),str("#"),str("Gets"),str("Ligature"),str("Separator"),str("Value"),str("Function"),str("Modifier"),str("Modifier2"),str("<tspan class=\'"),str("\'>"),str("\"&<>"),str("&"),str(";"),str("quot"),str("amp"),str("lt"),str("gt"),str("11111000000000010000022000"),str("000//232323223102303200121"),str("11111111111111011101111110"),str("00000110111001001101000100"),str("</tspan>"),str(" ⋄"),str("M VH"),str("text"),str("rect"),str("width"),str("height"),str("path"),str("d")]
     ,[[0,1,0,31],[0,0,516,4],[0,0,603,8],[0,0,723,3],[0,0,736,10],[0,0,987,3],[0,0,997,3],[0,0,1007,3],[0,0,1023,4],[0,0,1074,3],[1,1,1099,2],[0,0,1129,3],[0,0,1143,33],[0,0,2052,3],[1,0,2095,5],[0,0,2107,3],[0,0,2146,4],[0,0,2236,4],[1,1,2337,2],[0,1,2367,2],[0,0,2469,22],[0,0,2999,5],[0,0,3081,3]]
    );
    explain = (s,c) => {
      let e = doc.explain;
      e.innerHTML = s?drawEval(s,c).map(l=>l.join("")).join("\n"):'';
      setTimeout(() => {
        e.querySelectorAll('tspan').forEach(t => {
          let h = primhelp[t.textContent];
          if (!h) return;
          t.innerHTML = t.textContent+'<title>'+h+'</title>';
        });
      }, 0);
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
let keydesc='f+Conjugate;Add_f-Negate;Subtract_f×Sign;Multiply_f÷Reciprocal;Divide_f⋆Exponential;Power_f√Square Root;Root_f⌊Floor;Minimum_f⌈Ceiling;Maximum_f∧Sort Up;And_f∨Sort Down;Or_f¬Not;Span_f|Absolute Value;Modulus_f≤Less Than or Equal to_f<Enclose;Less Than_f>Merge;Greater Than_f≥Greater Than or Equal to_f=Rank;Equals_f≠Length;Not Equals_f≡Depth;Match_f≢Shape;Not Match_f⊣Identity;Left_f⊢Identity;Right_f⥊Deshape;Reshape_f∾Join;Join to_f≍Solo;Couple_f↑Prefixes;Take_f↓Suffixes;Drop_f↕Range;Windows_f«Shift Before_f»Shift After_f⌽Reverse;Rotate_f⍉Transpose;Reorder axes_f/Indices;Replicate_f⍋Grade Up;Bins Up_f⍒Grade Down;Bins Down_f⊏First Cell;Select_f⊑First;Pick_f⊐Classify;Index of_f⊒Occurrence Count;Progressive Index of_f∊Mark First;Member of_f⍷Deduplicate;Find_f⊔Group Indices;Group_f!Assert;Assert with message_m˙Constant_m˜Self/Swap_d∘Atop_d○Over_d⊸Before/Bind_d⟜After/Bind_d⌾Under_d⊘Valences_d◶Choose_d⎉Rank_m˘Cells_d⚇Depth_m¨Each_m⌜Table_d⍟Repeat_m⁼Undo_m´Fold_m˝Insert_m`Scan_g←Define_g⇐Export_g↩Change_g→Return_s⋄Separator_s,Separator_p(Begin expression_p)End expression_k{Begin block_k}End block_b⟨Begin list_b⟩End list_l‿Strand_n·Nothing_v•System_v𝕨Left argument_f𝕎Left argument (as function)_v𝕩Right argument_f𝕏Right argument (as function)_v𝕗Modifier left operand (as subject)_f𝔽Modifier left operand_v𝕘2-modifier right operand (as subject)_f𝔾2-modifier right operand_v𝕤Current function (as subject)_f𝕊Current function_m𝕣Current modifier_n¯Minus_nπPi_n∞Infinity_a@Null character_c#Comment'.split(/[\n_]/);
let kk=Array.from('`123456890-=~!@#$%^&*()_+qwertuiop[]QWERTIOP{}asdfghjkl;ASFGHKL:"zxcvbm,./XVBM<>? \'');
let kv=Array.from('˜˘¨⁼⌜´˝∞¯•÷×¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆⌽𝕨∊↑∧⊔⊏⊐π←→↙𝕎⍷𝕣⍋⊑⊒⍳⊣⊢⍉𝕤↕𝕗𝕘⊸∘○⟜⋄↖𝕊𝔽𝔾«⌾»·˙⥊𝕩↓∨⌊≡∾≍≠𝕏⍒⌈≢≤≥⇐‿↩');
let keys={}, revkeys={}, primhelp={};
kk.map((k,i)=>{keys[k]=kv[i];revkeys[kv[i]]=k;});
doc.kb.innerHTML = keydesc.map(d=>{
  let s = syncls[d[0]];
  let c = Array.from(d)[1];
  let t = d.slice(1+c.length).replace(';','\n');
  let k = revkeys[c]; if (k) t += '\n\\ '+(k==='"'?'&quot;':k);
  primhelp[c] = t;
  return '<span title="'+t+'" class="'+s+'">'+c+'</span>'
}).join("&#8203;"); // zero-width space
doc.kb.onmousedown = ev => {
  let t = ev.target;
  if (t.nodeName === 'SPAN') {
    return typeChar(doc.code, t.textContent, ev);
  }
}

if (doc.demo) {
  let fonts=[["DejaVu","Mod"],["BQN386"],["Fairfax","HD"],["3270","font"],["Iosevka","Term"],["Julia","Mono"]];
  let fclass = f => f==="3270"?"f"+f:f
  let fontsel = '<select>'+fonts.map(f =>
      '<option value="'+f[0]+'">'+f[0]+(f[1]?' '+f[1]:'')+'</option>'
    ).join("")+'select';
  doc.kb.innerHTML += fontsel;
  doc.kb.querySelector('select').onchange =
    e=>doc.cont.className='cont '+fclass(e.target.value);
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
  let code, run=1, ee=0;
  location.hash.slice(1).split('&').map(s => {
    if (s.slice(0,5)==='code=') code=s.slice(5);
    if (s.slice(0,5)==='norun') run=0;
    if (s.slice(0,7)==='explain') ee=1;
  });
  if (code!==undefined) {
    let b=atob(code);
    b=new Uint8Array([...b].map(c=>c.charCodeAt(0)));
    setcount(doc.code.value = (new TextDecoder()).decode(b));
    if (ee && doc.doexplain) doc.doexplain.onclick();
    if (run) repl();
  }
}
