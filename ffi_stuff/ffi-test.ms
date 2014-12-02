
;; Here we include the external C code
;; Making sure we don't actually evaluate it here, by jumping around it...
(asm "JMP .end")
(include-asm "working/ffitest.s")
(asm ".end:")

;; Define a scheme function which is a wrapper around our external call...
(define (myfunc x y z)
	(call-c-func "myfunc" x y z))

;; We call the external C function, and send the result via Serial
(serial-send
	(myfunc 5 2 7))