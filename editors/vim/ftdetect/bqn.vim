au BufRead,BufNewFile *.bqn setf bqn
au BufRead,BufNewFile * if getline(1) =~ '^#!.*bqn$' | setf bqn | endif
