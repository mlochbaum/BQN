#! /usr/bin/env node

const bqn=require(__dirname+'/../bqn.js')
    , load=f=>require('fs').readFileSync(__dirname+'/'+f,'utf8');

if (process.argv.length <= 2) {
  const t=load('cases.bqn').split('\n').filter(x=>x).map(x=>x.split(' % '))
      , test=t.map(e=>e[1])
      , expt=t.map(e=>+e[0]);
//let test= load('testref.bqn').split('\n')
//        .filter(x=>x.charAt(0)===' '
//                 &&x.charAt(1)===' '
//                 &&x.charAt(2)!=='#'
//                 &&x.indexOf(':')===-1
//                 &&x.indexOf('e¯')===-1)
//        .map(x=>x.slice(2))
//    , t=test.map(e=>[0,e])
//    , expt=test.map(e=>1);

  test.map((t,i) => {
    console.log(t);
    let e=expt[i], r=bqn(t);
    console.log(e===r ? " Passed!" : " Expected "+e+" but received "+r);
  });
} else {
  console.log(process.argv.slice(2).map(bqn));
}
