
(include "examples/max7.ms")

(define lcd (def-max7 2 4 3 1))

(decode lcd 0 #xFF)
(intensity lcd 0 #x00)
(scan-limit lcd 0 #x07)
(test lcd 0 #f)
(show lcd 0 #t)

(define (clear-dig x)
	(digit lcd 0 x #xF))

(define (clear-rest dig)
	(if (> dig 0)
		(begin
			(clear-dig dig)
			(clear-rest (- dig 1)))))

(define (print num dig)
	(if (> dig 0)
		(begin
			(digit lcd 0 dig (mod num 10))
			(set! num (div num 10))
			(if (> num 0)
				(print num (- dig 1))
				(clear-rest (- dig 1))))))

(define (loop it)
 	(print it 5)
 	(pause 50)
 	(loop (+ it 1)))

(loop 0)

