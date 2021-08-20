#! /usr/bin/env node

"use strict";
let path = require('path');
let fs = require('fs');

let bqn = require("./docs/bqn.js");
let {fmt,fmtErr,sysvals}=bqn;
let {has,list,str,unstr,dynsys,req1str,makens}=bqn.util;

let show = x => console.log(fmt(x));
sysvals.show = (x,w) => { show(x); return x; };
sysvals.out = (x,w) => { console.log(req1str("•Out",x,w)); return x; };

let dir = f=>f==='/'?f:f+'/'; // BQN uses trailing slash
let getres = p => {
  let res;
  if (p) { p=unstr(p); res = (e,f)=>path.resolve(p,f); }
  else { res = (e,f) => { if (!path.isAbsolute(f)) throw Error(e+": Paths must be absolute when not running from a file"); return f; }; }
  return e => (x,w) => res(e,req1str(e,x,w));
}
let withres = (e,fn) => dynsys(() => fn(getres(sysvals.path)(e)));
let ff = (fr,fw,o) => resolve => (x,w) => {
  let f = resolve(has(w)?w:x);
  if (has(w)) { fs.writeFileSync(f,fw(x),o); return str(f); }
  else { return fr(fs.readFileSync(f,o)); }
};
let fchars = ff(str,unstr,"utf-8");
let flines = ff(s=>list(s.replace(/\n$/,'').split('\n').map(str)),s=>s.map(unstr).join('\n')+'\n',"utf-8");
let fbytes = ff(s=>list(Array.from(s).map(c=>String.fromCodePoint(c))),s=>Buffer.from(s.map(c=>c.codePointAt(0))));
sysvals.fchars = withres("•FChars",fchars);
sysvals.flines = withres("•FLines",flines);
sysvals.fbytes = withres("•FBytes",fbytes);

sysvals.file = dynsys(() => {
  let p = sysvals.path;
  let res = getres(p);
  let files = {
    // Paths and parsing
    path: p,
    at: (x,w) => {
      let e="•file.At", f=res(e)(has(w)?w:x);
      return str(has(w)?path.resolve(f,req1str(e,x)):f);
    },
    name:      (x,w) => str(path.basename(req1str("•file.Name",x,w))),
    extension: (x,w) => str(path.extname (req1str("•file.Extension",x,w))),
    basename:  (x,w) => str(path.parse(req1str("•file.BaseName",x,w)).name),
    parent:    (x,w) => str(dir(path.dirname(res("•file.Parent")(x,w)))),
    parts:     (x,w) => { let p=path.parse(res("•file.Parts")(x,w));
                          return list([dir(p.dir),p.name,p.ext].map(str)); },

    // Metadata
    exists: (x,w) => fs.existsSync(res("•file.Exists")(x,w))?1:0,
    type: (x,w) => {
      let c = fs.constants;
      switch (c.S_IFMT & fs.lstatSync(res("•file.Type")(x,w)).mode) {
        case c.S_IFREG:  return 'f';
        case c.S_IFDIR:  return 'd';
        case c.S_IFLNK:  return 'l';
        case c.S_IFIFO:  return 'p';
        case c.S_IFSOCK: return 's';
        case c.S_IFBLK:  return 'b';
        case c.S_IFCHR:  return 'c';
      }
    },
    created:  (x,w) => fs.statSync(res("•file.Created" )(x,w)).birthtimeMs/1000,
    accessed: (x,w) => fs.statSync(res("•file.Accessed")(x,w)).atimeMs/1000,
    modified: (x,w) => fs.statSync(res("•file.Modified")(x,w)).mtimeMs/1000,
    size:     (x,w) => fs.statSync(res("•file.Size"    )(x,w)).size,
    permissions: (x,w) => {
      let f=res("•file.Permissions")(x);
      let mode=fs.statSync(f).mode;
      if (has(w)) {
        if (!w.sh||w.sh.length!==1||w.sh[0]!==3) throw Error("•file.Permissions: 𝕨 must be a list of 3 numbers");
        if (!w.every(n=>Number.isInteger(n)&&0<=n&&n<8)) throw Error("•file.Permissions: each permission must belong to ↕8");
        let p=0; w.map(n=>p=8*p+n);
        fs.chmodSync(f,(mode&fs.constants.S_IFMT)|p); return w;
      } else {
        let p=[]; for (let i=3;i--;) { p[i]=mode&7; mode=Math.floor(mode/8); }
        return list(p);
      }
    },
    owner: (x,w) => {
      let f=res("•file.Owner")(x);
      if (has(w)) {
        if (!w.sh||w.sh.length!==1||w.sh[0]!==2) throw Error("•file.Owner: 𝕨 must be a uid‿gid pair");
        fs.chownSync(f,w[0],w[1]); return w;
      } else {
        let s=fs.statSync(f); return list([s.uid,s.gid]);
      }
    },

    // Access
    rename:    (x,w) => {let r=res("•file.Rename"),f=r(w); fs.renameSync  (r(x),f); return str(f);},
    copy:      (x,w) => {let r=res("•file.Copy"  ),f=r(w); fs.copyFileSync(r(x),f); return str(f);},
    createdir: (x,w) => {let f=res("•file.CreateDir")(x,w); fs.mkdirSync(f); return str(f);},
    remove:    (x,w) => {fs.rmSync(res("•file.Remove")(x,w)); return 1;},
    removedir: (x,w) => {fs.rmSync(res("•file.RemoveDir")(x,w),{recursive:true,force:true}); return 1;},
    list:  (x,w) => list(fs.readdirSync(res("•file.List")(x,w)).map(str)),
    chars: fchars(res("•file.Chars")),
    lines: flines(res("•file.Lines")),
    bytes: fbytes(res("•file.Bytes")),
    // TODO Open Return an open file object based on 𝕩
  }
  return makens(Object.keys(files), Object.values(files));
});

let set_state = w => {
  w = w||[]; sysvals.state=list(w);
  sysvals.path=w[0]; sysvals.name=w[1]; sysvals.args=w[2];
}
let bqn_state = (x,w) => { set_state(w); return bqn(x); }
bqn.setreqexec((s,x,w) => { set_state(w); return req1str(s,x); });
sysvals.exit = (x,w) => process.exit(Number.isInteger(x)?x:0);
let bqn_file = (f,t,w) => bqn_state(
  t, [ str(dir(path.dirname(f))), str(path.basename(f)), w ]
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
    return [str(dir(path.resolve('.'))), s, list([],s)];
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
      let inp; while ((inp=stdin.read())!==null) {
        if (!/^[ \t]*[#\n]/.test(inp)) e(inp.toString());
      }
    });
  } else if (arg0[0] !== '-' || (arg0==='-f'&&(arg0=(args=args.slice(1))[0],1))) {
    let f=arg0, a=list(args.slice(1).map(str));
    exec(s=>bqn_file(f,s,a))(fs.readFileSync(f,'utf-8'));
  } else if (arg0 === '-e') {
    let st=cl_state();
    args.slice(1).map(exec(s=>show(bqn_state(s,st))));
  }
}
