;; Arduino LCD Library
;; microscheme.org

(include "libraries/ascii.ms")

(define lcdpins (vector 4 5 6 7 8 9))
;; lcdpins: d0 d1 d2 d3 rs en

(define (pulse)
	(set-pin (vector-ref lcdpins 5) #f)
	(micropause 1)
	(set-pin (vector-ref lcdpins 5) #t)
	(micropause 1)
	(set-pin (vector-ref lcdpins 5) #f)
	(micropause 1))

(define (write4bits val)
	(set-pin (vector-ref lcdpins 0) (not (zero? (mod val 2))))
	(set-pin (vector-ref lcdpins 1) (not (zero? (mod (div val 2) 2))))
	(set-pin (vector-ref lcdpins 2) (not (zero? (mod (div val 4) 2))))
	(set-pin (vector-ref lcdpins 3) (not (zero? (mod (div val 8) 2))))
	(pulse))

(define (send val mode)
	(set-pin (vector-ref lcdpins 4) mode)
	(write4bits (div val 16))
	(write4bits val))

(define (lcd-init)
	(for-each-vector (lambda (pin) (set-ddr pin #t)) lcdpins)
	(pause 50)
	(set-pin (vector-ref lcdpins 4) #f)
	(set-pin (vector-ref lcdpins 5) #f)
	(write4bits 3)
	(pause 5)
	(write4bits 3)
	(pause 5)
	(write4bits 3)
	(pause 5)
	(write4bits 2)
	(send 40 #f)
	(send 12 #f)
	(send 1 #f)
	(pause 2)
	(send 6 #f)
	(send 128 #f))

(define (write val)
	(send (if (char? val) (char->number val) val) #t))

(define (set-cursor row col)
	(send (+ 128 (+ col (* 64 row))) #f))

(define (clear)
	(send 1 #f)
	(micropause 2000))

(define (writenum val)
	(free!
		(for-each-vector write (trim-leading-zeros (number->ascii val)))))

(define (writestring str)
	(for-each-vector write str))


;; Now we define a polymorphic structural 'print' function
(define print)

(define (print-list-step lst delimit)
	(write delimit)
	(print (car lst))
	(if (null? (cdr lst))
		(write #\rparen)
		(print-list-step (cdr lst) #\space)))

(define (print-vector vect)
	(free!
		(write #\[)
		(print (vector-ref vect 0))
		(for 1 (- (vector-length vect) 1) (lambda (i)
			(write #\|)
			(print (vector-ref vect i))))
		(write #\])))

(define print (lambda (x)
	(if (number? x) (writenum x))
	(if (boolean? x) (writestring (if x "#t" "#f")))
	(if (char? x) (write x))
	(if (list? x) (print-list-step x #\lparen)
		(if (pair? x) (begin (write #\<) (print (car x)) (write #\space) (print (cdr x)) (write #\>))))
	(if (null? x) (writestring "()"))
	(if (string? x) (writestring x)
		(if (vector? x) (print-vector x)))
	(if (procedure? x) (begin (writestring "@p") (writenum (arity x))))))



;; numbers, booleans and chars are printed directly.
;; Strings are printed directly, other Vectors are printed as [1|2|3]
;; Lists are printed as (1 2 3), other Pairs are printed as <car cdr>
;; Procedures are printed as @pr