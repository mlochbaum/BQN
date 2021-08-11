*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/editors/index.html).*

# Editor support

<!--GEN
"style" Enc ".Comment,.Function,.Number,.String { color: inherit; }"
-->

Editor plugins and other tools for allowing BQN input are in [this folder](https://github.com/mlochbaum/BQN/tree/master/editors). Input is always performed with a backslash `\` prefix by default, using the layout shown [here](https://mlochbaum.github.io/BQN/keymap.html). To type an actual backslash, hit the backslash key twice.

[This bookmarklet](https://abrudz.github.io/lb/bqn) enables BQN input in any webpage in your **browser**.

[This userscript](https://gist.github.com/dzaima/35ca0ce12b5e215a62460f00e693984f) highlights BQN code on **GitHub**.

For **Android**, [this fork](https://github.com/dzaima/hackerskeyboard/releases/latest) adds APL and BQN to Hacker's Keyboard.

The file [inputrc](https://github.com/mlochbaum/BQN/blob/master/editors/inputrc) can be copied or appended to `~/.inputrc` to enable backslash input in **bash**, BQN with **rlwrap**, and other software that uses GNU Readline.

If you'd like to contribute files for another editor I'd gladly accept them!

## System-wide

### XKB (Unix)

The file [bqn](https://github.com/mlochbaum/BQN/blob/master/editors/bqn) is for configuring XKB on Linux, or other systems using X11. To use, copy it to `/usr/share/X11/xkb/symbols/`, then run

    $ setxkbmap -layout us,bqn -option grp:switch

replacing `us` with your ordinary keyboard layout. `switch` indicates the right alt key and can be replaced with `lswitch` for left alt or other codes. The setting will go away on shutdown so you will probably want to configure it to run every time you start up. The way to do this depends on your desktop environment. For further discussion, see [Wikipedia](https://en.wikipedia.org/wiki/X_keyboard_extension) or the [APL Wiki](https://aplwiki.com/wiki/Typing_glyphs_on_Linux).

Another XKB option, if you have a compose key enabled, is to place [XCompose](https://github.com/mlochbaum/BQN/blob/master/editors/XCompose) (possibly with adjustments) in `~/.XCompose`.

### Windows

Folder [autohotkey-win](https://github.com/mlochbaum/BQN/tree/master/editors/autohotkey-win) contains an [AutoHotKey](https://en.wikipedia.org/wiki/AutoHotKey) script and the generated .exe file. It runs as an ordinary program that recognizes BQN key combinations system-wide. Move it to the startup folder if you'd like to have it running all the time. You can right-click its icon in the system tray to disable it temporarily.

The [XCompose](https://github.com/mlochbaum/BQN/blob/master/editors/XCompose) file, although created for XKB, should also be usable with [WinCompose](https://github.com/samhocevar/wincompose) (but as far as I know this hasn't been tested).

## Text editors

### Vim

Copy or symlink all files into the corresponding directories in `~/.vim`. Add the following two lines to `~/.vim/filetype.vim`:

      au! BufRead,BufNewFile *.bqn setf bqn
      au! BufRead,BufNewFile * if getline(1) =~ '^#!.*bqn$' | setf bqn | endif

Include `syntax on` in your .vimrc for syntax highlighting and `filetype plugin on` for keyboard input.

### Emacs

Add the following two lines to `init.el` (usually `~/.emacs.d/init.el`), replacing the path appropriately.

    (add-to-list 'load-path "/path/to/BQN/editors/emacs")
    (require 'gnu-apl-mode)

### VS Code

See [this repository](https://github.com/razetime/bqn-vscode).

### Kakoune

Copy or symlink `kak/autoload/filetype/bqn.kak` into `autoload/filetype` in your Kakoune config directory (probably `.config/kak/`).
