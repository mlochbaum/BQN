BQN documentation exists in two places: markdown files, and corresponding HTML files in the `docs/` folder. When making a fix, you can save me 20 seconds or so by re-generating HTML pages for the markdown you edit. I would much rather have a correction with no HTML than no correction, so skip this if it seems inconvenient. However, for a small change also it's easier for me to just make the fix based on a forum comment than to merge, pull, re-generate, and push.

If you have [CBQN](https://github.com/dzaima/CBQN) installed as `bqn` somewhere in your shell path, you can generate files with

    $ ./gendocs [file.md...]

If no files are given, this builds all docs. It's a thin wrapper around `md.bqn`, and the following version lets you run without the shell path set up:

    $ /path/to/BQN md.bqn file.md...

With Node.js but no CBQN, you can also run JS BQN, which takes somewhere around 5 seconds plus 1-10 seconds per file.

    $ ./bqn.js md.bqn file.md...
