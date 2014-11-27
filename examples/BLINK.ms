;; Ryan Suchocki
;; microscheme.org

(define led-pin (output 10))

(define (loop)
	(toggle led-pin)
	(pause 1000))

(forever loop)
