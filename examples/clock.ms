;; ======================= Microscheme =======================
;; Clock example
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(define anodes (vector 2 3 4 5))
(define cathodes (vector 22 26 24 28 32 36 30 34))

(define db (vector #t #t #t #t #t #t #t #t))

(define digit (vector
	(vector #t #f #f #f #f #f #f #t)
	(vector #t #t #t #t #t #f #f #t)
	(vector #t #f #f #t #f #f #t #f)
	(vector #t #f #t #t #f #f #f #f)
	(vector #t #t #t #f #t #f #f #f)
	(vector #t #f #t #f #f #t #f #f)
	(vector #t #f #f #f #f #t #f #f)
	(vector #t #t #t #f #f #f #f #t)
	(vector #t #f #f #f #f #f #f #f)
	(vector #t #f #t #f #f #f #f #f)))

(define digits (vector 0 0 0 0))

(define (set-cathodes bits i)
	(set-pin (vector-ref cathodes i) (vector-ref bits i))
	(if (< i 7) (set-cathodes bits (+ i 1))))

(define (disp x y z w)
	(set-cathodes (vector-ref digit (vector-ref digits x)) 0)

	(high (vector-ref anodes x))
	(pause 5)
	(low (vector-ref anodes x))

	(if (= z 95)
		(begin
			(set! z 0)
			(set! w (not w))
			(set-pin 40 w))
		(set! z (+ z 1)))

	(if (< y 11340) (disp (if (= x 3) 0 (+ x 1)) (+ y 1) z w)))

(define mins 2)
(define secs 26)

(define (go)
	(vector-set! digits 0 (mod (div mins 10) 10))
	(vector-set! digits 1 (mod mins 10))

	(vector-set! digits 2 (mod (div secs 10) 10))
	(vector-set! digits 3 (mod secs 10))

	(disp 0 0 0 #t)
	(set! secs (+ secs 1))
	(if (= secs 60) (begin (set! secs 0) (set! mins (+ mins 1))))
	(if (= mins 24) (set! mins 0))
	(go))

(for-each-vector output anodes)
(for-each-vector low anodes)
(for-each-vector output cathodes)
(for-each-vector low cathodes)

(output 40)
(output 42)
(low 42)
(high 40)

(pause 220)
(go)
