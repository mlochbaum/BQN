#! /usr/bin/env node

"use strict";
let path = require('path');
let fs = require('fs');

let bqn = require("./docs/bqn.js");
let {fmt,fmtErr,sysvals}=bqn;
let {has,list,str,unstr,dynsys,req1str}=bqn.util;

let show = x => console.log(fmt(x));
sysvals.show = (x,w) => { show(x); return x; };
sysvals.out = (x,w) => { console.log(req1str("•Out",x,w)); return x; };

let getres = e => {
  let p = sysvals.path; let res;
  if (p) { p=unstr(p); res = f=>path.resolve(p,f); }
  else { res = f => { if (!path.isAbsolute(f)) throw Error(e+": Paths must be absolute when not running from a file"); return f; }; }
  return x => res(req1str(e,x));
}
let withres = (e,fn) => dynsys(() => fn(getres(e)));
let ff = (fr,fw,o) => resolve => (x,w) => {
  let f = resolve(has(w)?w:x);
  if (has(w)) { fs.writeFileSync(f,fw(x),o); return str(f); }
  else { return fr(fs.readFileSync(f,o)); }
};
let fchars = ff(str,unstr,"utf-8");
let flines = ff(s=>list(s.split('\n').map(str)),s=>s.map(unstr).join('\n'),"utf-8");
let fbytes = ff(s=>list(Array.from(s).map(c=>String.fromCodePoint(c))),s=>Buffer.from(s.map(c=>c.codePointAt(0))));
sysvals.fchars = withres("•FChars",fchars);
sysvals.flines = withres("•FLines",flines);
sysvals.fbytes = withres("•FBytes",fbytes);

let set_state = w => {
  w = w||[]; sysvals.state=list(w);
  sysvals.path=w[0]; sysvals.name=w[1]; sysvals.args=w[2];
}
let bqn_state = sysvals.bqn = (x,w) => { set_state(w); return bqn(x); }
sysvals.exit = (x,w) => process.exit(Number.isInteger(x)?x:0);
sysvals.bqn = (x,w) => bqn_state(req1str("•BQN",x), w);
let bqn_file = (f,t,w) => bqn_state(
  t, [ str(path.resolve(f,'..')+'/'), str(path.basename(f)), w ]
);
let imports = {};
sysvals.import = withres("•Import", resolve => (x,w) => {
  let f = resolve(x);
  let save = r=>r;
  if (!has(w)) {
    let c=imports[f]; if (has(c)) return c;
    save = r => (imports[f]=r);
    w=list([]);
  }
  return save(bqn_file(f, fs.readFileSync(f,'utf-8'), w));
});

if (!module.parent) {
  let args = process.argv.slice(2);
  let arg0 = args[0];
  let cl_state = () => {
    let s = str("");
    return [str(path.resolve(__dirname)+'/'), s, list([],s)];
  }
  let exec = fn => src => {
    try {
      fn(src);
    } catch(e) {
      console.error('[31m'+fmtErr(e)+'[39m');
    }
  }
  if (!has(arg0) || arg0==='-r') {
    set_state(cl_state());
    let stdin = process.stdin, repl = sysvals.makerepl();
    let e = exec(s=>show(repl(str(s))));
    stdin.on('end', () => { process.exit(); });
    stdin.on('readable', () => {
      let inp; while ((inp=stdin.read())!==null) { e(inp.toString()); }
    });
  } else if (arg0[0] !== '-' || (arg0==='-f'&&(arg0=(args=args.slice(1))[0],1))) {
    let f=arg0, a=list(args.slice(1).map(str));
    exec(s=>bqn_file(f,s,a))(fs.readFileSync(f,'utf-8'));
  } else if (arg0 === '-e') {
    let st=cl_state();
    args.slice(1).map(exec(s=>show(bqn_state(s,st))));
  }
}
