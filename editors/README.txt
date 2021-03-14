Editor plugins and other tools for allowing BQN input. Input is always
performed with a backslash prefix by default, using the layout
illustrated at the top of the file ./bqn . To type an actual backslash,
hit the backslash key twice.

The file bqn is for configuring XKB on Linux. I haven't tried this but
others have it working. See:
- https://en.wikipedia.org/wiki/X_keyboard_extension
- https://aplwiki.com/wiki/Typing_glyphs_on_Linux

The file inputrc can be copied or appended to ~/.inputrc to enable
backslash input in bash, command-line dzaima/BQN, and other software
that uses GNU Readline.

For Vim:
Copy or symlink all files into the corresponding directories in ~/.vim .
Add the following two lines to ~/.vim/filetype.vim :
  au! BufRead,BufNewFile *.bqn setf bqn
  au! BufRead,BufNewFile * if getline(1) =~ '^#!.*bqn$' | setf bqn | endif
Include "syntax on" in your .vimrc for syntax highlighting and
"filetype plugin on" for keyboard input.

For Emacs:
Add the following two lines to init.el (usually ~/.emacs.d/init.el),
replacing the path appropriately.
(add-to-list 'load-path "/path/to/BQN/editors/emacs")
(require 'gnu-apl-mode)

For Kakoune:
Copy or symlink kak/autoload/filetype/bqn.kak into autoload/filetype in
your Kakoune config directory (probably .config/kak/).

If you'd like to contribute files for another editor I'd gladly accept
them!
