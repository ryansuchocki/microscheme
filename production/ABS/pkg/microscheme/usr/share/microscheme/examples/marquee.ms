
(include "examples/lcd.ms")

(lcd-init)

(define marquee "Hello, world!   ")

(define (rotate vect)
	(free!
		(let ((carry (vector-ref vect 0)))
				(for 0 (- (vector-length vect) 2) 
					(lambda (i)
						(vector-set! vect i (vector-ref vect (+ i 1)))))
			(vector-set! vect (vector-last vect) carry))))

(define (loop)
	(set-cursor 0 0)
	(print marquee)
	(pause 500)
	(rotate marquee))

(forever loop)