Microscheme 
===========

Microscheme is a Scheme subset designed for Atmel microcontrollers, especially as found on Arduino boards.

Recent Changes
--------------

 1. Microscheme now has apply!
 2. Microscheme now has an FFI!

Compiling
---------

### Quick-Start

`$ make hexify`

`$ make build`

`$ ./microscheme examples/BLINK.ms`

If you have an arduino *on hand*:

`$ ./microscheme -m [MODEL] -d [/dev/WHATEVER] -auc examples/BLINK.ms`

### Detail

The microscheme source code is located in src/, and includes files written in C (.c, .h), assembly (.s)
and in microscheme (.ms). 

In order to compile microscheme, those source files written in assembly and microscheme are 'hexified', i.e.
converted into C byte arrays by invoking `$ make hexify`. Next, the compiler is compiled by invoking `$ make build`.

The result is a standalone binary called 'microscheme' which is entirely self-contained, and can be separated
from other files in this repository. On linux systems, invoke `$ sudo make install` to copy the binary to
/usr/local/bin/, thus making it available system-wide.

Usage
-----

As of the latest commit, the usage is:

```
Usage: microscheme [-auscvrio] [-m model] [-d device] [-p programmer] [-w filename] [-t rounds] program[.ms]

Option flags:
  -a    Assemble (implied by -u or -s) (requires -m)
  -u    Upload (requires -d)
  -s    Disassemble (to inspect final binary)
  -c    Cleanup (removes intermediate files)
  -v    Verbose
  -r    Verify (Uploading takes longer)
  -i    Allow the same file to be included more than once
  -o    Disable optimisations  
  -h    Show this help message 

Configuration flags:
  -m model       Specify a model (UNO/MEGA/LEO...)
  -d device      Specify a physical device
  -p programmer  Tell avrdude to use a particular programmer
  -w files       'Link' with external C or assembly files
  -t rounds      Specify the maximum number of tree-shaker rounds

```

Prerequisites
-------------

In order to compile microscheme, you will need some implementation of GCC and the unix utility XXD. (Readily 
available on Linux/OSX.)

In order to assemble programs and upload them to real Arduinos, you will need some implementation of *avr-gcc*, *avr-libc* and *avrdude*. Microscheme will try to invoke these tools directly, if the -a or -u options are used.
Packages are available on all good linux distro's:

For example, on Arch linux:

`$ sudo pacman -S avr-gcc avr-libc avrdude`

Or, on Ubuntu or Debian:

`$ sudo apt-get install gcc-avr avr-libc avrdude`

These tools are available via the [Homebrew](http://brew.sh/) and [MacPorts](https://www.macports.org/) package
managers on Mac OS X and the [winavr](http://winavr.sourceforge.net/) project on Windows.

Targets
-------

Microscheme currently supports the ATMega168/328 (used on the Arduino UNO), the ATMega2560 (used on most Arduino MEGA boards), and the ATMega32u4. The target controller is set using the command line argument `-m` follwed by `MEGA`, `UNO`, `LEO` or `KEYBOARDIO-ATREUS` (not required if you're just compiling).

Note: An Arduino Pro Mini with a 168/328 chip (programmed via an UNO board with its chip removed) can be treated as an UNO, because it uses the same chip.

Other chips can be supported by writing model definitions in [models.c](src/models.c), containing values derived from the relevant Atmel datasheet.

Compiler pipeline
-----------------

The entire compiler pipeline, as orchestrated by main.c, is:

> [source code] → lexer.c → [token tree] → parser.c → [abstract syntax tree] → scoper.c → [(scoped) AST] → treeshaker.c → [(reduced) AST] → codegen.c → [assembly code]  ...

If the -a (assemble) option is given:

> [assembly code] → avr-gcc → [ELF binary] → avr-objcopy → [IHEX binary]  ...

If the -u (upload) option is given:

> [IHEX binary] → avrdude → Arduino Device


License
-------

The MIT License (MIT)

Copyright (c) 2014 Ryan Suchocki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
