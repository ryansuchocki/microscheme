;; ======================= Microscheme =======================
;; Microscheme-C FFI demo
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

;; README:
;; To run this test, use the -w option to compile this file *with*
;; the C source file.
;;
;; $ microscheme -m ... -d ... -au -w ffi_stuff/ffitest.c ffi_stuff/ffi-test.ms

;; Define a scheme wrapper around each of our external functions...
(define (pow x y)
	(call-c-func "mathpow" x y))

(define (vectsum x)
	(call-c-func "vectsum" x))

(define (listsum x)
	(call-c-func "listsum" x))

;; We call each external C function, and send the result via Serial
(serial-send (pow 6 4))
(serial-send (vectsum (vector 2 3 5 6)))
(serial-send (listsum (list 2 3 5 6)))
