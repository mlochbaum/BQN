setlocal keymap=bqn

setlocal commentstring=#%s
setlocal matchpairs=(:),{:},[:],⟨:⟩
setlocal iskeyword=@,48-57,_,^×,^÷
setlocal ignorecase

setlocal shiftwidth=2 tabstop=2 softtabstop=2

nn<buffer><f1> :cal bqn#t()<cr>
