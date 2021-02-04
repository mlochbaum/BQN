Editor plugins and other tools for allowing BQN input. Input is always
performed with a backslash prefix by default, using the layout
illustrated at the top of the file ./bqn . To type an actual backslash,
hit the backslash key twice.

Currently Vim and Kakoune are supported; if you'd like to contribute
files for another editor I'd gladly accept them!

The file bqn is for configuring XKB on Linux. I haven't tried this but
others have it working. See:
- en.wikipedia.org/wiki/X_keyboard_extension
- https://aplwiki.com/wiki/Typing_glyphs_on_Linux

The file inputrc can be copied or appended to ~/.inputrc to enable
backslash input in bash, command-line dzaima/BQN, and other software
that uses GNU Readline.
