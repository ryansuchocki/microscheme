(serial-send
	(call-c-func "myfunc" 5 2 7))

(asm "JMP .end")
(include-asm "working/ffitest.s")
(asm ".end:")