let s:s=0|let s:f=expand('<sfile>:p:r').'.txt'
fu bqn#t() "toggle status line
 if s:s|let[s:s,s:a,&ls,&stl]=[0,[],s:ls,s:stl]|retu|en
 try|let s:a=readfile(s:f)|let g:sa=s:a|cat|let s:a=[]|endt
 let[s:s,s:ls,s:stl]=[1,&ls,&stl]
 let&ls=2|let&stl='%{bqn#l()}'
endf
fu bqn#l() "render content of status line
 let c=substitute(getline('.')[col('.')-1:]." ",'\(\_.\)\_.*','\1','')
 for x in s:a|if c=~#'\V'.x[:len(c)-1]|retu x|en|endfo|retu c
endf
