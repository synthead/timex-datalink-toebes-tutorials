# Toebes' WristApp tutorial sources for the Timex Datalink

This repository contains the source code for the tutorials and header files from John A. Toebes, VIII's
[Datalink Wristapp Developer's Resource](https://www.toebes.com/Datalink) website!  You can use the identical code
examples in this repository while you follow his excellent tutorials.

To assemble WristApps for the Timex Datalink 150 and 150s, please use
[Toebes' assembler](https://www.toebes.com/Datalink/wristapps.html).  For your convenience, here's
[Toebes' assembler wrapped in Docker with Wine](https://github.com/synthead/timex-datalink-wristapp-assembler) to make
it easier to use on the CLI in a platform-agnostic way.

## Highlighting in Vim

To make ZSM be highlighted correctly in Vim, set the syntax to "asm", like so:

```vimrc
:syntax=asm
```

To make Vim set the syntax to "asm" automatically when ZSM files are opened or created, add this to your `.vimrc`:

```vimrc
au BufRead,BufNewFile *.zsm set syntax=asm
```
