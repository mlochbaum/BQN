//usr/bin/env node "$0" $@;exit $?
const bqn=require(require('os').homedir+'/bin/bqn')
    , load=f=>require('fs').readFileSync(__dirname+'/'+f,'utf8')
    , runWasm=w=>new WebAssembly.Instance(new WebAssembly.Module(Uint8Array.from(w)))
                 .exports.fn()

const t=load('cases.bqn').split('\n').filter(x=>x).map(x=>x.split(' % '))
    , test=t.map(e=>'"'+e[1]+'"').join('\n')
    , expt=t.map(e=>+e[0])
    , rslt=bqn(load('../c.bqn','utf8').concat('Compile¨⟨'+test+'⟩'))
           .a.map((a,i)=>runWasm(a.a))
    , pass=rslt.map((r,i)=>r===expt[i])
    , fail=pass.map((p,i)=>p?-1:i).filter(i=>i>=0)
console.log(
    fail.length
    ? fail.map(i=>'"'+t[i][1]+'": expected '+expt[i]+' but received '+rslt[i])
    : "All passed!"
)
process.exit(+(fail.length>0))
