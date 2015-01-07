# Microscheme makefile
# (C) 2014 Ryan Suchocki
# microscheme.org

all: hexify build

hexify:
	echo "// Hexified internal microscheme files." > src/assembly_hex.c
	xxd -i src/preamble.s >> src/assembly_hex.c

	echo "// Hexified internal microscheme files." > src/microscheme_hex.c
	xxd -i src/primitives.ms >> src/microscheme_hex.c
	xxd -i src/stdlib.ms >> src/microscheme_hex.c

build:
	gcc -ggdb -std=gnu99 -Wall -Wextra -o microscheme src/*.c

install:
	sudo install -m755 ./microscheme /usr/local/bin

