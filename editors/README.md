*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/editors/index.html).*

# Editor support

<!--GEN
"style" Enc ".Comment,.Function,.Number,.String { color: inherit; }"
-->

Editor plugins and other tools for allowing BQN input are in [this folder](https://github.com/mlochbaum/BQN/tree/master/editors). Input always uses the layout shown [here](https://mlochbaum.github.io/BQN/keymap.html) ([want another?](#alternate-layouts)), and is usually performed with a backslash `\` prefix, but sometimes with a modifier key such as alt. To type an actual backslash, hit the backslash key twice.

Both the online REPL and CBQN support backslash input with no configuration required.

[Beacon](https://github.com/x86y/beacon) is **a dedicated IDE** designed for BQN.

[This bookmarklet](https://abrudz.github.io/lb/bqn) enables BQN input in any webpage in your **browser**.

For **Android**, [this fork](https://github.com/dzaima/hackerskeyboard/releases/latest) adds APL and BQN to Hacker's Keyboard.

For **iPhone**, [this repository](https://github.com/gitonthescene/APLKeyboard) includes a BQN keyboard for the Pythonista IDE.

The file [inputrc](https://github.com/mlochbaum/BQN/blob/master/editors/inputrc) can be copied or appended to `~/.inputrc` to enable backslash input in **bash**, BQN with **rlwrap**, and other software that uses GNU Readline.

Support for other editors, OSes, or workflows will be gladly accepted!

## System-wide

### XKB (Unix)

The file [bqn](https://github.com/mlochbaum/BQN/blob/master/editors/bqn) is for configuring XKB on Linux, or other systems using X11. It's installed as part of xkeyboard-config 2.36 and later, or can be copied to `/usr/share/X11/xkb/symbols/` for earlier versions. Then run

    $ setxkbmap -layout us,bqn -option grp:switch

replacing `us` with your ordinary keyboard layout. `switch` indicates the right alt key and can be replaced with `lswitch` for left alt or other codes. The setting will go away on shutdown, so you will probably want to configure it to run every time you start up. The way to do this depends on your desktop environment. For further discussion, see [Wikipedia](https://en.wikipedia.org/wiki/X_keyboard_extension) or the [APL Wiki](https://aplwiki.com/wiki/Typing_glyphs_on_Linux).

Another XKB option is to place [XCompose](https://github.com/mlochbaum/BQN/blob/master/editors/XCompose) (possibly with adjustments) in `~/.XCompose` and enable a compose key. This can be done using either OS-specific settings or the following command:

    $ setxkbmap -option compose:rwin

### Windows

Folder [autohotkey-win](https://github.com/mlochbaum/BQN/tree/master/editors/autohotkey-win) contains an [AutoHotKey](https://en.wikipedia.org/wiki/AutoHotKey) script and the generated .exe file. It runs as an ordinary program that recognizes BQN key combinations system-wide, using the right alt key (to change this, replace `RAlt` in the script and rebuild). Move it to the startup folder if you'd like to have it running all the time. You can right-click its icon in the system tray to disable it temporarily.

The [XCompose](https://github.com/mlochbaum/BQN/blob/master/editors/XCompose) file, although created for XKB, is also usable with [WinCompose](https://github.com/samhocevar/wincompose).

### Mac

There are two keyboard layouts: [one](https://github.com/mlochbaum/BQN/blob/master/editors/BQN.keylayout) enables BQN keys with the `Alt` modifier, and [another](https://github.com/mlochbaum/BQN/blob/master/editors/BQN_backslash.keylayout) uses the standard `\` prefix.

To install:
- Copy the appropriate `.keylayout` file to `~/Library/Keyboard Layouts/`.
- Navigate to System Preferences > Keyboard > Input Sources > + > Others > BQN.
- Restart, then enable the BQN keyboard with System Preferences > Keyboard > Input Sources > BQN US.
Don't use the root-based directory `/Library/Keyboard Layouts/` for the first step, as this will silently fail.

## Text editors

### Cross-editor support

[bqnlsp](https://git.sr.ht/~detegr/bqnlsp) implements [Language Server Protocol](https://en.wikipedia.org/wiki/Language_Server_Protocol) support for BQN, which allows code evaluation with error reporting. After building, see instructions for [VSCode](https://git.sr.ht/~detegr/bqnlsp/tree/master/item/editors/vscode/README.md), [Neovim](https://git.sr.ht/~detegr/bqnlsp/tree/master/item/editors/neovim/nvim-lspconfig/README.md), or [Helix](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers#bqn).

[tree-sitter-bqn](https://github.com/shnarazk/tree-sitter-bqn) implements [tree-sitter](https://tree-sitter.github.io/tree-sitter/) support, and includes instructions for [Helix](https://github.com/shnarazk/tree-sitter-bqn). Many other editors such as Neovim and emacs allow for tree-sitter integration.

### Vim

Copy or symlink all files into the corresponding directories in `~/.vim`. Add the following two lines to `~/.vim/filetype.vim`:

      au! BufRead,BufNewFile *.bqn setf bqn
      au! BufRead,BufNewFile * if getline(1) =~ '^#!.*bqn$' | setf bqn | endif

Include `syntax on` in your .vimrc for syntax highlighting and `filetype plugin on` for keyboard input. View docs from vim with `:help bqn`.

To use vim-plug to install BQN support for vim, add this to your plugin section of your `.vimrc`:

      Plug 'mlochbaum/BQN', {'rtp': 'editors/vim'}

Then run `:PlugInstall`.

#### Neovim interactivity

See [nvim-bqn](https://git.sr.ht/~detegr/nvim-bqn) for an additional plugin that provides bindings to run BQN code as you're editing it.

### Emacs

Emacs support now lives on [museoa/bqn-mode](https://github.com/museoa/bqn-mode). Clone and add the following two lines to your init file (usually `~/.emacs.d/init.el`), replacing the path appropriately.

    (add-to-list 'load-path "/path/to/bqn-mode")
    (require 'bqn-mode)

### VS Code

See [bqn-vscode](https://github.com/mk12/bqn-vscode), or install directly through [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=mk12.bqn) or [Open VSX Registry](https://open-vsx.org/extension/mk12/bqn).

### Kakoune

Copy or symlink [the file](kak/autoload/filetype/bqn.kak) `kak/autoload/filetype/bqn.kak` into `autoload/filetype` in your Kakoune config directory (probably `~/.config/kak/`).

### Micro

See [micro-bqn](https://github.com/0racle/micro-bqn).

### Zed

BQN support as implemented by [zed-bqn](https://github.com/DavidZwitser/zed-bqn) can be installed from the extension tab.

## Alternate layouts

All files here use the BQN layout designed for qwerty, which will generally be jumbled in another layout (for example the key for `r` will still type `↑`, but it may not be above `c`, which types `↓`). The [remap.bqn](remap.bqn) script allows you to remap some files in this repository to a new layout. See `$ ./remap.bqn -h` for usage. Support for a new layout can be added in the `keys` array of the script, but do watch for string alignment with the doubled quote character.

(If you haven't installed CBQN but have Node.js, `$ bqn.js editors/remap.bqn…` from the repository root will work too)
