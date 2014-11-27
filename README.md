microscheme
===========

Microscheme is a Scheme subset/variant designed for the Atmel microcontrollers, especially as found on Arduino boards.

Compiling
---------

The microscheme source code is located in src/, and includes files written in C (.c, .h), assembly (.s)
and in microscheme (.ms). 

In order to compile microscheme, those source files written in assembly and microscheme are 'hexified', i.e.
converted into C byte arrays by invoking `$ make hexify`. Next, the compiler is compiled by invoking `$ make build`.

The result is a standalone binary called 'microscheme' which is entirely self-contained, and can be separated
from other files in this repository. On linux systems, invoke `$ sudo make install` to copy the binary to
/usr/local/bin/, thus making it available system-wide.

Prerequisites
-------------

In order to compile microscheme, you will need some implementation of GCC and the unix utility XXD. (Readily 
available on Linux/OSX.)

In order to assemble programs and upload them to real Arduinos, you will need some implementation of *avr-gcc*
and *avrdude*. Microscheme will try to invoke these tools directly, if the -a or -u options are used.
Packages are available on all good linux distro's:

For example, on Arch linux:

`$ sudo pacman -S avr-gcc`

`$ sudo pacman -S avrdude`

Or, on Ubuntu:

`$ sudo apt-get install gcc-avr`

`$ sudo apt-get install avrdude`

The [winavr](http://winavr.sourceforge.net/) project provides implementations of these tools for Windows.

Targets
-------

Microscheme currently supports the ATMega168/328 (used on the Arduino UNO), and the ATMega2560 (used on most Arduino MEGA boards). The target controller is set using the command line argument `-m` follwed by `MEGA` or `UNO` (not required if you're just compiling).

Note: An Arduino Pro Mini with a 128/328 chip (programmed via an UNO board with its chip removed) can be treated as a UNO, because it uses the same chip. In this case, just tell microscheme it's an UNO with `-m UNO`, and it should work...

Other chips could be supported by writing header files to match [MEGA.s](src/MEGA.s) and [UNO.s](src/UNO.s), which contain values derived from the relevant Atmel datasheet. You will also need to add extra cases to the makefile, codegen.c and main.c to accomodate the new model.

Compiler pipeline
-----------------

The entire compiler pipeline, as orchistrated by main.c, is:

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