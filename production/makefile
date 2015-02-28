# Microscheme production makefile
# (C) 2014 Ryan Suchocki
# microscheme.org

VERSION=0.9.2
BUILDN=$(shell cat buildnum)


publish:
	expr `cat buildnum` + 10 > buildnum # increment build number
	-mv *.tar.gz archive/
	-mv *.zip archive/

	-mkdir microscheme_linux32
	gcc -m32 -o microscheme_linux32/microscheme ../src/*.c
	cp -R ../examples microscheme_linux32/examples
	cp ../LICENSE microscheme_linux32/
	cp ../README.md microscheme_linux32/
	# -cp -R release/common/* linux32
	# -cp -R release/common_linux/* linux32
	tar -zcvf microscheme_${VERSION}_linux_32.tar.gz microscheme_linux32/
	rm -R microscheme_linux32

	-mkdir microscheme_linux64
	gcc -m32 -o microscheme_linux64/microscheme ../src/*.c
	cp -R ../examples microscheme_linux64/examples
	cp ../LICENSE microscheme_linux64/
	cp ../README.md microscheme_linux64/
	# -cp -R release/common/* linux64
	# -cp -R release/common_linux/* linux64
	tar -zcvf microscheme_${VERSION}_linux_64.tar.gz microscheme_linux64/
	rm -R microscheme_linux64

	-mkdir microscheme_win32
	i686-w64-mingw32-gcc -o microscheme_win32/microscheme.exe ../src/*.c 
	cp -R ../examples microscheme_win32/examples
	cp ../LICENSE microscheme_win32/
	cp ../README.md microscheme_win32/
	# -cp -R release/common/* win32
	# -cp -R release/common_windows/* win32
	zip -r microscheme_${VERSION}_win_32.zip microscheme_win32/
	rm -R microscheme_win32

	-mkdir microscheme_win64
	x86_64-w64-mingw32-gcc -o microscheme_win64/microscheme.exe ../src/*.c 
	cp -R ../examples microscheme_win64/examples
	cp ../LICENSE microscheme_win64/
	cp ../README.md microscheme_win64/
	# -cp -R release/common/* win64
	# -cp -R release/common_windows/* win64
	zip -r microscheme_${VERSION}_win_64.zip microscheme_win64/
	rm -R microscheme_win64



