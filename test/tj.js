#! /usr/bin/env node

let bqn = require(__dirname+'/../bqn.js');
let load = f=>require('fs').readFileSync(__dirname+'/'+f,'utf8');
let args = process.argv.slice(2);
let ref = args[0]==="-ref";

if (ref || args.length==0) {
  let t = (load('cases.bqn')+load('bcases.bqn'))
          .split('\n').filter(x=>x).map(x=>x.split(' % '));
  let test = t.map(e=>e[1]);
  let expt = t.map(e=>+e[0]);
  if (ref) {
    let r = load('testref.bqn').split('\n')
            .filter(x=>x.charAt(0)===' '
                     &&x.charAt(1)===' '
                     &&x.charAt(2)!=='#'
                     &&x.indexOf(':')===-1)
            .map(x=>x.slice(2));
    test = test.concat(r);
    expt = expt.concat(r.map(e=>1));
  }

  let rslt = test.map(bqn);
  let pass = rslt.map((r,i)=>r===expt[i]);
  let fail = pass.map((p,i)=>p?-1:i).filter(i=>i>=0);
  console.log(
      fail.length
      ? fail.map(i=>'"'+test[i]+'": expected '+expt[i]+' but received '+rslt[i])
      : "All "+test.length+" passed!"
  );
} else {
  console.log(args.map(bqn));
}
