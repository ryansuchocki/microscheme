;; FFI Demo
;; microscheme.org

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
