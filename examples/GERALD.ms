;; ======================= Microscheme =======================
;; Fractal-drawing robot example
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(define mleft	(list 4 5 6 7))
(define mright	(list 8 9 10 11))

(define reverse-mleft (reverse mleft))
(define reverse-mright (reverse mright))

(for-each output mleft)
(for-each output mright)

(define (cycle2 m1 m2)
	(or (null? m1) (null? m2)
		(begin
			(high (car m1))
			(high (car m2))
			(pause 4)
			(low (car m1))
			(low (car m2))
			(cycle2 (cdr m1) (cdr m2)))))
			
(define (forward x) (free!
	(for 1 (* x 32) (lambda (_) 
		(cycle2 mleft mright)))))

(define (right x) (free!
	(for 1 (div (* x 256) 45) (lambda (_) 
		(cycle2 mleft reverse-mright)))))

(define (left x) (free!
	(for 1 (div (* x 256) 45) (lambda (_) 
		(cycle2 reverse-mleft mright)))))

(define (segment level)
	(if (zero? level)
		(forward 3)
		(begin
			(segment (- level 1))
			(left 60)
			(segment (- level 1))
			(right 120)
			(segment (- level 1))
			(left 60)
			(segment (- level 1)))))

(segment 2)