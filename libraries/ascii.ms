;; ======================= Microscheme =======================
;; ASCII library
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(define zerocode (char->number #\0))

(define (number->ascii n)
	(vector
		(+ (mod (div n 10000) 10) zerocode)
		(+ (mod (div n 1000) 10) zerocode)
		(+ (mod (div n 100) 10) zerocode)
		(+ (mod (div n 10) 10) zerocode)
		(+ (mod n 10) 48)))

(define (long->ascii ln)
	(vector
		(+ (mod (div (car ln) 1000) 10) zerocode)
		(+ (mod (div (car ln) 100) 10) zerocode)
		(+ (mod (div (car ln) 10) 10) zerocode)
		(+ (mod (car ln) 10) zerocode)
		(+ (mod (div (cdr ln) 1000) 10) zerocode)
		(+ (mod (div (cdr ln) 100) 10) zerocode)
		(+ (mod (div (cdr ln) 10) 10) zerocode)
		(+ (mod (cdr ln) 10) zerocode)))

(define (charzero? x)
	(= x zerocode))

(define (charnotzero? x)
	(not (= x zerocode)))

(define (trim-leading-zeros vect)
	(sub-vector vect (vector-first vect charnotzero?) (- (vector-length vect) 1)))