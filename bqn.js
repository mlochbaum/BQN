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
  let p = sysvals.path;
  if (p) { p=unstr(p); return f=>path.resolve(p,f); }
  return f => { if (!path.isAbsolute(f)) throw Error(e+": Paths must be absolute when not running from a file"); return f; };
}
let withres = (e,fn) => dynsys(() => fn(getres(e)));
let ff = (e,fr,fw,o) => withres(e, resolve => (x,w) => {
  let f = resolve(req1str(e,has(w)?w:x));
  if (has(w)) { fs.writeFileSync(f,fw(x),o); return str(f); }
  else { return fr(fs.readFileSync(f,o)); }
});
sysvals.fchars = ff("•FChars",str,unstr,"utf-8");
sysvals.flines = ff("•FLines",s=>list(s.split('\n').map(str)),s=>s.map(unstr).join('\n'),"utf-8");
sysvals.fbytes = ff("•FBytes",s=>list(Array.from(s).map(c=>String.fromCodePoint(c))),s=>Buffer.from(s.map(c=>c.codePointAt(0))));
let bqn_state = sysvals.bqn = (x,w) => {
  w = w||[];
  sysvals.path=w[0]; sysvals.name=w[1]; sysvals.args=w[2];
  return bqn(x);
}
sysvals.bqn = (x,w) => bqn_state(req1str("•BQN",x), w);
let bqn_file = (f,t,w) => bqn_state(
  t, [ str(path.resolve(f,'..')+'/'), str(path.basename(f)), w ]
);
let imports = {};
sysvals.import = withres("•Import", resolve => (x,w) => {
  let f = resolve(req1str("•Import",x));
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
  let exec = fn => src => {
    try {
      fn(src);
    } catch(e) {
      console.error('[31m'+fmtErr(e)+'[39m');
    }
  }
  if (arg0[0] !== '-' || (arg0==='-f'&&(arg0=(args=args.slice(1))[0],1))) {
    let f=arg0, a=list(args.slice(1).map(str));
    exec(s=>bqn_file(f,s,a))(fs.readFileSync(f,'utf-8'));
  } else if (arg0 === '-e') {
    args.slice(1).map(exec(s=>show(bqn_state(s))));
  }
}
