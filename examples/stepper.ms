;; Microscheme steper-motor library
;; Ryan Suchocki. microscheme.org

(include "libraries/list.ms")
; include once?

; length of coil pulses, in milliseconds
(define _pulse-pause 2)

; motor is a vector of pins
(define (init-stepper motor)
	(for-each-vector output motor))


(define rev1 512)

(define (step-pulse pin)
	(high pin)
	(pause _pulse-pause)
	(low pin))

(define (cycle-cw motor cycles)
	(if (> cycles 0)
		(begin
			(for-each-vector step-pulse motor)
			;(micropause _pulse-pause)
			(cycle-cw motor (- cycles 1)))))

(define (cycle-ccw motor cycles)
	(if (> cycles 0)
		(begin
			(for-each-vector-reverse step-pulse motor)
			;(micropause _pulse-pause)
			(cycle-ccw motor (- cycles 1)))))