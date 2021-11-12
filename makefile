# Microscheme makefile
# (C) 2014 Ryan Suchocki
# microscheme.org

PREFIX?=/usr/local

all: check build
hexify: src/assembly_hex.c src/microscheme_hex.c
build: microscheme

src/assembly_hex.c: src/*.s
	echo "// Hexified internal microscheme files." > src/assembly_hex.c
	xxd -i src/preamble.s >> src/assembly_hex.c

src/microscheme_hex.c: src/*.ms
	echo "// Hexified internal microscheme files." > src/microscheme_hex.c
	xxd -i src/primitives.ms >> src/microscheme_hex.c
	xxd -i src/stdlib.ms >> src/microscheme_hex.c
	xxd -i src/avr_core.ms >> src/microscheme_hex.c

microscheme: hexify src/*.h src/*.c
	gcc -ggdb -std=gnu99 -Wall -Wextra -Werror -o microscheme src/*.c

check:
	cppcheck --enable=all --inconclusive --std=c11 --error-exitcode=2 src

install:
	install -d $(PREFIX)/bin/
	install -m755 ./microscheme $(PREFIX)/bin/microscheme
	install -d $(PREFIX)/share/microscheme/
	cp -r examples/ $(PREFIX)/share/microscheme/

clean:
	-rm microscheme
	-rm src/*.o
	-rm src/assembly_hex.c
	-rm src/microscheme_hex.c
