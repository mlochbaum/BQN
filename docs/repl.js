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
      let out=[]; sysvals.show = (x,w) => { out.push(x); return x; }
      let c=compile(src);
      setExplain(src,c);
      out.push(run.apply(null,c));
      doc.rslt.textContent=out.map(fmt).join('\n');
    } catch(e) {
      doc.rslt.classList.add('err');
      doc.rslt.textContent=fmtErr(e);
    }
    sysvals.js=dojs; // In case it was disabled by fragment loading
  }, 0);
}
if (doc.run) doc.run.onclick = repl;
let exp=0, explain;
if (doc.doexplain) doc.doexplain.onclick = () => {
  if (explain===undefined) {
    let drawEval = run(
      [0,19,22,0,0,11,22,0,1,11,14,15,1,22,0,2,11,14,15,2,22,0,3,11,14,15,3,22,0,4,11,14,15,4,22,0,5,11,14,0,20,0,46,21,0,5,8,0,31,9,0,20,0,50,31,0,5,8,15,5,3,3,0,52,0,16,0,5,0,56,10,8,22,0,6,11,14,21,0,6,21,0,6,0,41,0,21,7,0,69,10,0,21,9,0,24,0,55,10,15,6,3,3,0,52,0,16,0,5,0,56,10,8,22,0,7,11,14,0,43,15,7,7,0,21,0,82,10,22,0,8,11,14,0,55,0,53,21,0,8,0,46,0,11,8,8,0,21,9,0,49,0,21,8,22,0,9,11,14,15,8,22,0,10,11,14,21,0,6,0,40,0,22,7,0,85,0,86,3,2,10,22,0,11,11,14,21,0,9,0,46,31,0,4,8,22,0,12,11,14,15,9,22,0,13,11,14,0,63,0,64,3,2,22,0,14,11,14,0,56,0,55,3,2,0,2,21,0,14,6,22,0,15,11,14,0,56,0,57,3,2,0,3,21,0,14,6,0,0,0,58,0,65,3,2,6,22,0,16,11,14,0,61,22,0,17,11,14,0,89,21,0,10,5,22,0,18,11,14,0,90,21,0,10,5,22,0,19,11,14,0,92,21,0,10,0,91,6,22,0,20,11,14,0,93,21,0,10,0,91,6,22,0,21,11,14,0,94,21,0,10,0,91,6,22,0,22,11,14,0,95,31,0,10,0,91,6,22,0,23,11,14,0,96,0,97,0,21,0,61,0,25,5,0,0,0,70,6,6,0,98,0,99,0,100,0,101,0,102,0,103,0,104,0,105,0,106,0,107,0,21,0,73,6,0,21,0,84,6,0,108,0,109,3,14,0,20,0,46,0,56,3,2,6,0,27,5,0,40,0,11,7,5,22,0,24,22,0,25,4,2,11,14,0,110,0,111,0,112,0,113,0,114,0,115,0,116,3,7,0,21,22,0,24,13,14,15,10,21,0,25,7,22,0,26,11,14,31,0,24,0,41,15,11,7,5,22,0,27,11,14,0,119,22,0,28,11,14,0,122,0,123,0,124,0,125,3,4,0,41,0,121,0,49,0,21,8,0,21,0,120,10,7,5,22,0,29,11,14,15,12,22,0,30,11,25,0,55,0,18,31,0,2,6,0,54,0,17,0,39,0,20,7,0,55,0,56,3,2,10,0,49,0,39,0,41,0,24,0,21,0,75,10,0,21,0,23,10,7,7,8,8,22,0,3,11,14,31,0,1,21,1,1,0,48,21,1,0,0,31,0,50,31,0,3,8,9,0,21,0,48,0,11,8,0,41,0,55,7,10,8,5,25,15,13,22,0,3,11,14,0,76,21,0,2,0,77,3,3,0,21,5,22,0,4,11,14,0,78,21,0,2,0,28,0,69,0,13,31,0,2,6,0,45,0,9,7,5,6,0,77,3,3,0,21,5,22,0,5,11,14,21,0,1,0,16,5,22,0,6,11,0,11,0,55,6,22,0,7,11,14,31,0,5,21,0,7,0,54,0,11,0,46,0,20,8,8,0,47,15,14,31,0,1,31,0,7,0,54,15,15,8,5,7,8,31,0,4,6,0,21,5,25,0,76,31,0,1,0,80,3,3,0,21,5,25,21,0,1,0,60,0,49,0,11,8,0,9,0,11,0,48,0,59,8,10,5,0,43,0,9,7,5,0,37,5,14,0,61,22,0,3,11,0,39,0,4,7,0,57,6,22,0,4,11,14,0,70,0,1,0,81,6,22,0,5,22,0,6,4,2,11,14,0,58,0,11,21,0,1,6,22,0,7,11,14,31,0,1,0,7,5,22,0,8,11,14,31,0,8,0,2,21,0,4,6,0,0,0,62,6,0,5,5,22,0,9,11,14,31,0,7,0,28,5,0,41,31,0,5,7,0,49,0,11,0,47,0,22,8,8,5,0,22,5,21,0,4,0,3,21,0,9,6,0,5,5,15,16,0,48,0,13,0,46,0,25,8,8,5,31,0,9,15,17,0,48,0,13,0,46,0,25,8,8,5,0,13,0,11,0,58,10,0,54,0,21,0,48,0,30,0,46,0,26,0,31,9,0,50,0,41,31,0,6,7,8,8,8,8,5,3,3,0,21,5,0,27,5,0,40,0,21,0,46,0,11,8,7,5,0,43,0,0,0,48,0,70,8,0,49,0,36,8,7,5,25,31,0,1,14,0,58,0,37,5,25,31,0,1,14,0,58,0,37,5,25,31,0,2,0,83,31,0,1,0,84,3,4,0,21,5,25,15,18,22,0,3,11,14,31,0,1,21,0,3,0,72,7,5,0,41,31,0,3,0,71,7,7,5,0,41,21,1,8,7,0,21,9,0,49,0,21,8,0,51,0,12,8,31,0,2,17,25,31,0,1,21,1,3,0,88,31,0,2,21,1,7,5,3,2,21,1,9,0,87,6,6,25,0,32,0,48,21,0,1,0,21,5,8,0,29,31,0,1,0,41,0,13,7,5,0,45,0,0,7,5,10,25,0,118,0,21,31,0,1,6,0,21,0,117,6,25,31,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,22,0,8,4,2,22,0,9,4,6,11,14,0,126,0,127,0,128,0,129,3,4,0,39,0,1,7,0,70,6,22,0,10,22,0,11,22,0,12,22,0,13,4,4,11,14,15,19,22,0,14,11,14,21,0,3,31,0,7,3,2,0,41,0,28,0,48,21,0,14,8,7,5,0,41,0,24,7,0,58,0,65,3,2,6,22,0,15,22,0,16,4,2,11,14,31,0,11,0,30,21,0,15,6,22,0,17,11,0,14,0,65,6,22,0,18,11,14,31,0,14,0,28,5,0,39,0,28,0,48,21,0,18,8,0,50,0,18,0,0,0,55,10,0,39,0,30,7,21,0,3,10,8,7,22,0,17,13,14,31,0,12,0,30,21,0,15,6,0,31,0,48,0,65,8,0,50,0,55,8,5,22,0,19,11,14,21,0,17,0,1,21,0,19,6,0,45,0,0,7,5,22,0,20,11,14,21,0,20,0,31,0,65,6,0,14,0,55,6,0,37,5,14,21,0,17,0,11,0,58,6,22,0,21,11,0,2,0,48,0,2,0,48,21,0,19,8,0,45,0,0,7,9,8,5,22,0,22,11,14,31,0,19,0,8,31,0,17,6,0,28,5,0,30,0,48,0,33,0,0,21,0,20,0,49,0,30,8,10,0,29,0,47,0,30,0,48,0,29,8,8,31,0,20,0,24,0,65,6,10,8,5,22,0,23,11,14,31,0,21,0,8,5,0,23,0,48,0,13,8,21,0,23,6,22,0,24,11,14,21,0,1,15,20,31,0,9,6,22,0,25,22,0,26,22,0,27,4,3,11,14,21,0,23,15,21,5,0,13,0,54,0,39,0,30,7,8,5,0,39,0,30,7,21,0,27,0,30,21,0,24,0,45,0,0,7,5,0,39,0,1,7,0,55,6,6,6,0,24,0,65,6,22,0,28,11,14,0,66,0,21,21,0,28,6,22,0,29,11,14,21,0,23,0,18,0,22,0,30,10,31,0,18,0,1,21,0,29,6,0,30,21,0,23,6,0,13,31,0,28,6,0,15,21,0,24,6,0,28,5,6,22,0,30,11,14,21,0,22,0,22,31,0,29,6,0,0,0,62,0,67,3,2,6,0,2,21,1,14,6,0,27,5,21,1,6,5,0,30,31,0,30,6,0,44,0,39,0,40,0,26,0,49,0,21,8,0,41,0,21,7,0,132,10,0,21,9,0,46,0,11,8,7,7,7,5,22,0,31,11,14,21,0,22,0,30,31,0,23,0,28,21,0,24,6,6,0,41,0,22,0,2,21,1,14,10,0,0,21,1,16,10,0,46,21,1,11,21,1,9,0,133,10,8,7,31,0,27,6,22,0,32,11,14,21,1,15,0,2,0,56,0,58,3,2,6,0,0,31,0,1,0,13,5,31,0,22,0,43,0,6,7,5,0,0,0,56,6,3,2,0,2,21,1,14,6,6,22,0,33,11,14,21,0,33,21,1,6,5,0,40,0,22,7,0,135,0,136,3,2,6,0,21,21,1,15,0,1,5,21,1,11,5,6,0,21,21,1,19,6,21,1,12,0,134,6,0,11,5,31,0,25,21,1,3,0,133,6,0,11,5,31,0,31,0,41,0,19,0,11,0,47,0,22,8,0,138,10,0,21,21,1,18,10,21,1,12,0,137,10,7,5,31,0,26,0,41,0,21,7,0,19,0,41,21,1,3,7,31,0,32,10,0,47,0,11,0,47,0,22,8,8,0,41,0,31,0,48,0,55,8,7,10,5,0,41,21,1,3,7,21,1,22,21,1,23,3,2,6,21,1,3,21,1,21,6,3,4,0,41,0,20,7,5,0,21,5,21,1,3,21,1,20,6,21,1,13,21,1,17,0,2,0,56,6,0,0,31,0,33,6,0,38,0,56,7,0,3,0,39,0,1,7,10,0,39,0,1,7,21,1,15,0,0,21,1,17,6,10,0,39,0,21,7,0,18,10,0,48,0,6,0,48,0,68,0,58,3,2,8,8,5,6,25,31,0,1,0,20,5,0,58,0,46,0,37,8,0,11,0,20,9,0,19,0,41,31,0,0,7,0,21,9,3,4,0,52,0,16,0,5,0,57,10,8,5,25,31,0,2,31,0,4,31,0,1,3,3,25,31,0,1,0,20,5,21,1,6,0,15,0,57,6,0,54,0,41,21,1,3,7,0,21,9,8,5,0,41,0,21,0,48,0,79,8,7,5,25,21,0,1,0,15,21,1,3,6,22,0,3,11,14,31,0,2,31,0,1,3,2,0,22,0,26,0,31,9,0,50,0,7,0,48,21,1,3,8,8,0,21,0,43,0,28,0,48,21,0,3,8,0,47,21,1,3,0,49,0,3,8,0,5,9,0,49,31,0,0,8,8,7,10,3,2,0,52,31,0,3,0,43,0,10,7,5,8,5,25,21,0,1,0,7,21,1,4,6,22,0,1,12,0,2,5,22,0,3,11,14,31,0,1,0,58,0,56,3,2,0,25,5,0,28,0,48,21,0,3,8,0,47,0,2,0,48,21,1,3,8,0,49,31,0,0,0,21,21,1,4,0,49,0,3,8,0,5,9,0,49,0,11,0,47,0,22,8,8,10,8,8,3,2,0,52,31,0,3,0,43,0,10,7,5,8,31,0,2,17,25,0,36,0,48,0,14,0,48,31,0,1,8,0,1,0,48,0,8,0,2,0,45,0,0,7,10,8,9,8,25,21,1,3,0,19,0,2,0,12,0,48,0,13,8,10,0,39,0,30,7,0,18,10,21,1,10,6,0,0,0,55,6,0,0,21,1,3,0,13,5,0,25,5,6,22,0,0,11,14,0,19,0,31,0,65,10,0,14,0,58,10,0,54,15,22,8,22,0,1,11,14,31,0,0,0,41,0,58,7,0,21,0,55,10,21,0,1,0,13,0,49,0,21,8,10,0,23,0,13,10,5,25,31,0,2,22,0,3,22,0,4,22,0,5,22,0,6,22,0,7,4,5,11,14,21,2,25,0,13,5,22,0,8,11,14,21,0,1,0,30,21,0,6,6,21,2,26,5,0,14,0,48,21,0,8,8,0,2,0,1,10,0,0,0,19,10,31,0,4,0,0,0,57,6,0,0,31,0,8,6,6,0,39,0,30,7,21,2,27,6,22,0,9,11,14,21,0,7,0,41,0,130,7,5,22,0,10,11,14,21,0,9,0,21,21,0,10,6,22,0,11,11,14,0,61,0,0,0,74,6,0,14,21,0,1,6,0,28,5,22,0,12,11,14,21,0,1,0,30,0,48,21,0,12,8,0,50,0,131,0,30,21,0,6,0,34,31,0,12,6,6,8,5,22,0,1,12,14,21,0,1,0,32,21,2,28,6,22,0,13,11,0,12,0,48,0,13,8,21,2,28,6,22,0,14,11,0,8,5,0,28,5,22,0,15,11,14,21,0,13,0,28,21,0,14,6,0,39,0,30,7,21,2,29,6,0,39,0,21,7,22,0,11,13,14,0,55,0,1,21,0,6,6,0,21,21,0,7,6,0,21,31,0,14,0,28,5,6,0,28,21,0,11,0,41,0,13,7,5,6,0,21,21,0,15,6,0,29,5,22,0,16,11,14,31,0,11,0,21,5,0,21,21,0,1,0,30,31,0,15,6,6,0,30,21,0,16,6,22,0,17,11,14,0,55,0,21,21,2,29,0,41,0,13,7,5,6,0,30,31,0,13,6,22,0,18,11,14,21,0,17,0,28,0,48,0,13,0,46,0,25,8,0,12,21,0,18,0,43,0,0,7,5,10,0,30,31,0,16,10,8,5,22,0,19,11,14,31,0,9,21,0,7,0,0,0,55,6,0,42,0,28,7,0,23,31,0,1,0,13,5,10,0,45,0,0,7,9,0,47,0,12,0,2,0,18,10,8,21,0,6,6,0,39,0,1,7,0,55,6,0,28,31,0,18,6,0,39,0,36,7,31,0,19,6,31,0,10,3,3,0,12,5,0,27,5,0,40,0,11,7,5,22,0,20,11,14,21,1,16,0,28,21,1,24,6,0,32,21,0,6,6,22,0,21,11,14,31,0,17,31,0,20,0,30,21,0,21,6,0,56,0,3,31,0,7,0,0,31,0,6,6,6,0,30,31,0,21,6,3,3,25,21,0,1,0,29,5,22,0,3,11,0,39,0,30,7,31,0,1,6,22,0,4,11,14,21,1,15,0,13,5,0,25,5,0,30,0,48,21,0,4,0,35,5,8,0,50,21,1,13,0,30,21,1,15,6,0,30,21,0,4,6,0,14,31,0,4,0,33,5,6,0,39,0,28,7,31,0,3,6,8,5,25,21,0,1,0,30,0,48,21,0,2,0,28,31,0,1,6,8,0,50,0,41,0,55,7,8,5,21,1,1,31,0,2,0,39,0,30,7,5,6,25]
     ,[runtime[0],runtime[1],runtime[2],runtime[3],runtime[4],runtime[6],runtime[7],runtime[8],runtime[9],runtime[10],runtime[11],runtime[12],runtime[13],runtime[14],runtime[15],runtime[16],runtime[18],runtime[19],runtime[20],runtime[21],runtime[22],runtime[23],runtime[24],runtime[25],runtime[26],runtime[27],runtime[30],runtime[31],runtime[32],runtime[33],runtime[35],runtime[36],runtime[37],runtime[38],runtime[39],runtime[40],runtime[41],runtime[42],runtime[43],runtime[44],runtime[45],runtime[46],runtime[48],runtime[49],runtime[50],runtime[51],runtime[52],runtime[53],runtime[54],runtime[55],runtime[56],runtime[57],runtime[58],runtime[59],runtime[61],1,2,3,0,-Infinity,Infinity,10,0.5,10.84,24,-1,-1.25,0.1,512,' ','0','=','|','\"','\0',str("t"),str("<"),str(">"),str("</"),str("  "),str("/>"),str("-."),str(" "),str("=\'"),str("\'"),str("x"),str("y"),str("svg"),str("viewBox"),str("stroke=currentColor|fill=none|stroke-width=1"),str("class=code|stroke-width=1|rx=10"),str("g"),str("font-family=BQN,monospace|font-size=18px|class=Paren|fill=currentColor"),str("font-size=15px|text-anchor=middle"),str("class=codeCover|stroke-width=8|stroke-linejoin=round"),str("opacity=0.9"),str("Number"),str("¯.π∞"),str("Paren"),str("()"),str("Bracket"),str("⟨⟩"),str("Brace"),str("{}"),str("Nothing"),str("·"),str("String"),str("@"),str("Comment"),str("#"),str("Gets"),str("Ligature"),str("Separator"),str("Value"),str("Function"),str("Modifier"),str("Modifier2"),str("<tspan class=\'"),str("\'>"),str("\"&<>"),str("&"),str(";"),str("quot"),str("amp"),str("lt"),str("gt"),str("11111000000000010000022000111012"),str("000//232323223102303200121111100"),str("11111111111111011101111110111011"),str("00000110111001001101000100000000"),str("</tspan>"),str(" ⋄"),str("M VH"),str("text"),str("rect"),str("width"),str("height"),str("path"),str("d")]
     ,[[0,1,0],[0,0,1],[0,0,[[],[2]]],[0,0,3],[0,0,4],[0,0,5],[0,0,6],[0,0,[[],[7]]],[0,0,8],[0,0,[[],[9]]],[1,1,10],[0,0,11],[0,0,[[],[12]]],[0,0,13],[1,0,[[],[14]]],[0,0,15],[0,0,[[],[16]]],[0,0,17],[1,1,18],[0,1,19],[0,0,[[],[20]]],[0,0,21],[0,0,[[],[22]]]]
     ,[[0,31],[516,4],[603,8],[723,3],[736,10],[987,3],[997,3],[1007,3],[1023,4],[1074,3],[1099,2],[1129,3],[1143,34],[2055,3],[2098,5],[2110,3],[2149,4],[2239,4],[2340,2],[2370,2],[2472,22],[3002,5],[3084,3]]
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

let makePlot;
sysvals.plot = (x,w) => {
  if (!makePlot) makePlot = run(
    [0,19,22,0,0,11,22,0,1,11,14,15,1,22,0,2,11,14,15,2,22,0,3,11,14,15,3,22,0,4,11,14,15,4,22,0,5,11,14,0,20,0,40,21,0,5,8,0,30,9,0,20,0,44,31,0,5,8,15,5,3,3,0,46,0,16,0,5,0,50,10,8,22,0,6,11,14,21,0,6,21,0,6,0,36,0,21,7,0,62,10,0,21,9,0,24,0,49,10,15,6,3,3,0,46,0,16,0,5,0,50,10,8,22,0,7,11,14,0,38,15,7,7,0,21,0,75,10,22,0,8,11,14,0,49,0,47,21,0,8,0,40,0,11,8,8,0,21,9,0,43,0,21,8,22,0,9,11,14,15,8,22,0,10,11,14,21,0,6,0,35,0,22,7,0,78,0,79,3,2,10,22,0,11,11,14,21,0,9,0,40,31,0,4,8,22,0,12,11,14,15,9,22,0,13,11,14,0,57,22,0,14,11,14,0,55,0,20,0,50,6,22,0,15,11,14,0,82,21,0,10,5,22,0,16,11,14,0,83,21,0,10,5,22,0,17,11,14,0,84,21,0,10,5,22,0,18,11,14,0,86,31,0,10,0,85,6,22,0,19,11,14,0,19,0,11,0,41,0,22,8,0,88,10,0,21,0,18,10,21,0,12,0,87,10,22,0,20,11,14,15,10,22,0,21,11,14,15,11,22,0,22,11,14,15,12,22,0,23,11,25,0,49,0,18,31,0,2,17,0,48,0,17,0,34,0,20,7,0,49,0,50,3,2,10,0,43,0,34,0,36,0,24,0,21,0,68,10,0,21,0,23,10,7,7,8,8,22,0,3,11,14,31,0,1,21,1,1,0,42,21,1,0,0,30,0,44,31,0,3,8,9,0,21,0,42,0,11,8,0,36,0,49,7,10,8,5,25,15,13,22,0,3,11,14,0,69,21,0,2,0,70,3,3,0,21,5,22,0,4,11,14,0,71,21,0,2,0,28,0,62,0,13,31,0,2,17,0,39,0,9,7,5,17,0,70,3,3,0,21,5,22,0,5,11,14,21,0,1,0,16,5,22,0,6,11,0,11,0,49,6,22,0,7,11,14,31,0,5,21,0,7,0,48,0,11,0,40,0,20,8,8,0,41,15,14,31,0,1,31,0,7,0,48,15,15,8,5,7,8,31,0,4,6,0,21,5,25,0,69,31,0,1,0,73,3,3,0,21,5,25,21,0,1,0,54,0,43,0,11,8,0,9,0,11,0,42,0,53,8,10,5,0,38,0,9,7,5,0,32,5,14,0,55,22,0,3,11,0,34,0,4,7,0,51,6,22,0,4,11,14,0,63,0,1,0,74,6,22,0,5,22,0,6,4,2,11,14,0,52,0,11,21,0,1,6,22,0,7,11,14,31,0,1,0,7,5,22,0,8,11,14,31,0,8,0,2,21,0,4,6,0,0,0,56,6,0,5,5,22,0,9,11,14,31,0,7,0,28,5,0,36,31,0,5,7,0,43,0,11,0,41,0,22,8,8,5,0,22,5,21,0,4,0,3,21,0,9,6,0,5,5,15,16,0,42,0,13,0,40,0,25,8,8,5,31,0,9,15,17,0,42,0,13,0,40,0,25,8,8,5,0,13,0,11,0,52,10,0,48,0,21,0,42,0,29,0,40,0,26,0,30,9,0,44,0,36,31,0,6,7,8,8,8,8,5,3,3,0,21,5,0,27,5,0,35,0,21,0,40,0,11,8,7,5,0,38,0,0,0,42,0,63,8,0,43,0,31,8,7,5,25,31,0,1,14,0,52,0,32,5,25,31,0,1,14,0,52,0,32,5,25,31,0,2,0,76,31,0,1,0,77,3,4,0,21,5,25,15,18,22,0,3,11,14,31,0,1,21,0,3,0,65,7,5,0,36,31,0,3,0,64,7,7,5,0,36,21,1,8,7,0,21,9,0,43,0,21,8,0,45,0,12,8,31,0,2,17,25,31,0,1,21,1,3,0,81,31,0,2,21,1,7,16,3,2,21,1,9,0,80,6,6,25,21,0,1,0,52,0,12,0,42,0,66,8,0,20,0,40,0,38,0,9,7,8,9,3,2,0,46,0,14,0,15,0,49,10,8,0,41,0,9,0,45,0,19,8,8,21,0,2,17,0,32,0,89,6,14,21,0,1,0,17,0,30,0,58,10,0,41,0,16,8,0,45,0,49,8,21,0,2,17,0,32,0,90,6,14,31,0,1,0,49,0,47,0,19,0,11,0,41,0,22,8,0,18,0,45,0,17,0,30,0,58,10,0,25,9,8,10,0,11,9,8,31,0,2,17,0,20,5,25,21,0,1,0,16,0,41,0,22,8,21,0,2,17,22,0,3,11,14,31,0,1,0,33,21,0,3,7,0,14,0,49,10,0,38,0,9,7,9,0,32,0,91,10,0,18,21,1,21,10,0,36,31,0,0,7,0,20,0,40,0,21,8,9,3,2,0,46,31,0,3,0,38,0,5,7,5,0,15,0,50,6,8,31,0,2,17,25,31,0,1,21,1,22,31,0,2,17,0,12,5,0,27,5,0,5,0,6,0,42,0,1,8,0,18,10,0,59,6,22,0,3,11,14,21,0,3,0,35,0,21,0,40,0,11,8,7,5,22,0,4,11,14,21,0,4,0,36,0,38,0,6,7,0,22,0,38,0,5,7,10,7,5,22,0,5,11,0,36,0,39,0,34,0,1,7,7,7,5,22,0,6,11,14,21,0,6,0,36,0,30,7,0,49,6,0,38,0,34,0,3,7,7,5,0,11,0,42,0,61,8,0,10,0,12,0,42,0,60,0,3,5,8,10,0,48,0,49,8,5,22,0,7,11,14,31,0,7,0,2,0,22,0,18,10,21,1,14,6,22,0,8,11,14,0,19,0,36,15,19,7,31,0,6,0,36,0,38,15,20,7,7,5,0,30,0,42,0,49,8,0,44,15,21,8,5,10,22,0,9,11,14,31,0,4,21,0,9,5,0,2,21,0,8,6,0,12,5,0,27,5,21,1,6,5,0,31,31,0,3,0,29,5,0,36,0,13,7,5,0,28,5,6,0,36,15,22,7,5,22,0,10,11,14,21,1,15,0,0,21,0,8,6,21,1,6,5,0,35,0,22,7,0,94,0,95,3,2,6,0,21,0,50,0,3,21,1,15,6,0,1,5,21,1,11,5,6,0,21,21,1,18,6,21,1,12,0,93,6,0,11,5,0,52,31,0,9,5,0,2,0,42,0,50,0,25,5,0,34,0,37,0,14,7,7,5,8,0,18,0,40,0,26,8,0,35,0,21,7,0,2,10,21,0,8,10,21,1,6,9,0,36,0,21,7,0,97,0,35,0,21,0,42,0,96,8,7,5,10,0,35,0,21,0,40,0,11,8,7,9,0,28,0,49,0,43,0,15,8,0,9,0,15,0,42,0,52,8,10,10,5,0,36,21,1,20,0,42,21,1,16,8,7,5,31,0,10,0,36,21,1,20,0,42,21,1,17,8,7,5,3,3,0,36,0,20,7,5,0,21,5,21,1,3,21,1,19,6,21,1,13,21,1,15,0,2,0,50,6,0,0,31,0,8,6,0,21,21,1,15,0,1,5,6,6,25,31,0,1,0,20,5,0,52,0,40,0,32,8,0,11,0,20,9,0,19,0,36,31,0,0,7,0,21,9,3,4,0,46,0,16,0,5,0,51,10,8,5,25,31,0,2,31,0,4,31,0,1,3,3,25,31,0,1,0,20,5,21,1,6,0,15,0,51,6,0,48,0,36,21,1,3,7,0,21,9,8,5,0,36,0,21,0,42,0,72,8,7,5,25,21,0,1,0,15,21,1,3,6,22,0,3,11,14,31,0,2,31,0,1,3,2,0,22,0,26,0,30,9,0,44,0,7,0,42,21,1,3,8,8,0,21,0,38,0,28,0,42,21,0,3,8,0,41,21,1,3,0,43,0,3,8,0,5,9,0,43,31,0,0,8,8,7,10,3,2,0,46,31,0,3,0,38,0,10,7,5,8,5,25,21,0,1,0,7,21,1,4,6,22,0,1,12,0,2,5,22,0,3,11,14,31,0,1,0,52,0,50,3,2,0,25,5,0,28,0,42,21,0,3,8,0,41,0,2,0,42,21,1,3,8,0,43,31,0,0,0,21,21,1,4,0,43,0,3,8,0,5,9,0,43,0,11,0,41,0,22,8,8,10,8,8,3,2,0,46,31,0,3,0,38,0,10,7,5,8,31,0,2,17,25,0,31,0,42,0,14,0,42,31,0,1,8,0,1,0,42,0,8,0,2,0,39,0,0,7,10,8,9,8,25,31,0,1,31,0,2,5,25,0,19,0,34,0,1,7,31,0,2,19,0,34,0,3,7,31,0,1,10,25,31,0,1,0,8,9,25,31,0,1,0,49,0,47,0,36,0,21,7,8,0,92,6,0,20,5,0,21,5,0,30,0,44,0,67,8,5,25]
   ,[runtime[0],runtime[1],runtime[2],runtime[3],runtime[4],runtime[6],runtime[7],runtime[8],runtime[9],runtime[10],runtime[11],runtime[12],runtime[13],runtime[14],runtime[15],runtime[16],runtime[18],runtime[19],runtime[20],runtime[21],runtime[22],runtime[23],runtime[24],runtime[25],runtime[26],runtime[27],runtime[30],runtime[31],runtime[32],runtime[35],runtime[36],runtime[41],runtime[42],runtime[43],runtime[44],runtime[45],runtime[46],runtime[47],runtime[49],runtime[51],runtime[52],runtime[53],runtime[54],runtime[55],runtime[56],runtime[57],runtime[58],runtime[59],runtime[61],1,2,3,0,-Infinity,Infinity,10,0.5,384,-1,1e+300,4,1.5,' ','0','=','|','\0','M',str("t"),str("<"),str(">"),str("</"),str("  "),str("/>"),str("-."),str(" "),str("=\'"),str("\'"),str("x"),str("y"),str("svg"),str("viewBox"),str("class=Paren|stroke=currentColor|stroke-width=1"),str("class=red|style=fill:none|stroke-width=1"),str("class=code|stroke-width=1|rx=5"),str("g"),str("font-family=BQN,monospace|font-size=18px"),str("path"),str("d"),str("•Plot: 𝕨 and 𝕩 must consist of rows of numbers"),str("•Plot: 𝕨 and 𝕩 must have the same length"),str("•Plot: invalid depth mixing"),str("L "),str("rect"),str("width"),str("height"),str("M "),str("VH")]
   ,[[0,1,0],[0,0,1],[0,0,[[],[2]]],[0,0,3],[0,0,4],[0,0,5],[0,0,6],[0,0,[[],[7]]],[0,0,8],[0,0,[[],[9]]],[0,0,10],[0,0,11],[0,0,12],[0,0,13],[1,0,[[],[14]]],[0,0,15],[0,0,[[],[16]]],[0,0,17],[1,1,18],[0,0,[[],[19]]],[0,0,20],[0,0,21],[0,0,22]]
   ,[[0,24],[321,4],[408,8],[528,3],[541,10],[792,3],[802,3],[812,3],[828,4],[879,3],[904,3],[1033,4],[1121,11],[1609,3],[1652,5],[1664,3],[1703,4],[1793,4],[1894,2],[1924,3],[1932,3],[1953,3],[1960,3]]
  );
  doc.explain.innerHTML = makePlot(x,w).map(l=>l.join("")).join("\n");
  setExplain = () => doc.explain.innerHTML = '';
  return '\0';
}

let keymode=0; // 1 for prefix
let prefix='\\';
doc.code.onkeydown = ev => {
  let k = ev.which;
  if (16<=k && k<=20) {
    return;
  } if (k==13 && (ev.shiftKey||ev.ctrlKey||ev.altKey||ev.metaKey)) { // *-enter
    repl(); return false;
  } if (keymode) {
    keymode = 0;
    doc.kb.classList.remove('prefix');
    let c = keys[ev.key];
    if (c) return typeChar(ev.target, c, ev);
  } else if (ev.key==prefix) {
    keymode = 1;
    doc.kb.classList.add('prefix');
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
let keydesc='f+Conjugate;Add_f-Negate;Subtract_f×Sign;Multiply_f÷Reciprocal;Divide_f⋆Exponential;Power_f√Square Root;Root_f⌊Floor;Minimum_f⌈Ceiling;Maximum_f∧Sort Up;And_f∨Sort Down;Or_f¬Not;Span_f|Absolute Value;Modulus_f≤Less Than or Equal to_f<Enclose;Less Than_f>Merge;Greater Than_f≥Greater Than or Equal to_f=Rank;Equals_f≠Length;Not Equals_f≡Depth;Match_f≢Shape;Not Match_f⊣Identity;Left_f⊢Identity;Right_f⥊Deshape;Reshape_f∾Join;Join to_f≍Solo;Couple_f↑Prefixes;Take_f↓Suffixes;Drop_f↕Range;Windows_f«Shift Before_f»Shift After_f⌽Reverse;Rotate_f⍉Transpose;Reorder axes_f/Indices;Replicate_f⍋Grade Up;Bins Up_f⍒Grade Down;Bins Down_f⊏First Cell;Select_f⊑First;Pick_f⊐Classify;Index of_f⊒Occurrence Count;Progressive Index of_f∊Mark First;Member of_f⍷Deduplicate;Find_f⊔Group Indices;Group_f!Assert;Assert with message_m˙Constant_m˜Self/Swap_d∘Atop_d○Over_d⊸Before/Bind_d⟜After/Bind_d⌾Under_d⊘Valences_d◶Choose_d⎊Catch_d⎉Rank_m˘Cells_d⚇Depth_m¨Each_m⌜Table_d⍟Repeat_m⁼Undo_m´Fold_m˝Insert_m`Scan_g←Define_g⇐Export_g↩Change_g→Return_s⋄Separator_s,Separator_v.Namespace field_p(Begin expression_p)End expression_k{Begin block_k}End block_b⟨Begin list_b⟩End list_l‿Strand_n·Nothing_v•System_v𝕨Left argument_f𝕎Left argument (as function)_v𝕩Right argument_f𝕏Right argument (as function)_v𝕗Modifier left operand (as subject)_f𝔽Modifier left operand_v𝕘2-modifier right operand (as subject)_f𝔾2-modifier right operand_v𝕤Current function (as subject)_f𝕊Current function_m𝕣Current modifier_n¯Minus_nπPi_n∞Infinity_a@Null character_c#Comment'.split(/[\n_]/);
let kk=Array.from('`123456890-=~!@#$%^&*()_+qwertuiop[]QWERTIOP{}asdfghjkl;ASFGHKL:"zxcvbm,./XVBM<>? \'');
let kv=Array.from('˜˘¨⁼⌜´˝∞¯•÷×¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆⌽𝕨∊↑∧⊔⊏⊐π←→↙𝕎⍷𝕣⍋⊑⊒⍳⊣⊢⍉𝕤↕𝕗𝕘⊸∘○⟜⋄↖𝕊𝔽𝔾«⌾»·˙⥊𝕩↓∨⌊≡∾≍≠𝕏⍒⌈≢≤≥⇐‿↩');
let keys={}, revkeys={}, primhelp={};
kk.map((k,i)=>{keys[k]=kv[i];revkeys[kv[i]]=k;});
doc.kb.innerHTML = keydesc
  .map(d=>'<span class="'+syncls[d[0]]+'">'+Array.from(d)[1]+'</span>')
  .concat(['<a href="keymap.html" target="_blank">map</a>'])
  .join("&#8203;"); // zero-width space
let setPrefix = () => {
  doc.kb.querySelectorAll("span").forEach((x,i) => {
    let d = keydesc[i];
    let c = Array.from(d)[1];
    let t = d.slice(1+c.length).replace(';','\n');
    let k = revkeys[c]; if (k) t += '\n'+prefix+(k==='"'?'&quot;':k);
    x.title = primhelp[c] = t;
  });
}
setPrefix();
doc.kb.onmousedown = ev => {
  let t = ev.target;
  if (t.nodeName === 'SPAN') {
    return typeChar(doc.code, t.textContent, ev);
  }
}

let appendHTML = (e,a) => e.insertAdjacentHTML('beforeend', a);
appendHTML(doc.kb, '<div class="kbext"></div>');
doc.kbext = doc.kb.querySelector('.kbext');

if (doc.demo) {
  let fonts=[["BQN386"],["DejaVu","Mod"],["Fairfax","HD"],["3270","font"],["Iosevka","Term"],["Julia","Mono"]];
  let fclass = f => f==="3270"?"f"+f:f
  let fontsel = '<select>'+fonts.map(f =>
      '<option value="'+f[0]+'">'+f[0]+(f[1]?' '+f[1]:'')+'</option>'
    ).join("")+'select';
  appendHTML(doc.kbext, fontsel);
  doc.kbext.querySelector('select').onchange =
    e=>doc.cont.className='cont '+fclass(e.target.value);
}

appendHTML(doc.kbext, '<input class="prfx" type="text" maxlength="1" value="'+prefix+'"/>');
doc.kbext.querySelector(".prfx").onchange = ev => {
  prefix = ev.target.value; setPrefix();
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
   ,'Life←{∨´1‿𝕩∧3‿4=+˝⥊⌽⟜𝕩¨1-˜↕3‿3}\nLife⍟(↕4) 6‿6↑(1⊸=∨5⊸≤)3‿3⥊↕9'
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
    let b=new Uint8Array([...atob(code)].map(c=>c.charCodeAt(0)));
    let c=doc.code.value=(new TextDecoder()).decode(b);
    setcount(c); doc.code.rows = Math.max(doc.code.rows, 1+c.split("\n").length);
    if (ee && doc.doexplain) doc.doexplain.onclick();
    nojs = () => { throw Error("Possible script injection; press Run to confirm"); }
    if (run) { sysvals.js=nojs; repl(); }
    doc.code.focus();
  }
}
