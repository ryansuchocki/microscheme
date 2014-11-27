;; Ryan Suchocki
;; microscheme.org







(define (factorial n)
  (if (zero? n)
    1
    (begin (serial-send (stacksize))(* (factorial (- n 1)) n))))

;(serial-send (factorial 7))





(define (tail-factorial n acc)
  (if (zero? n)
    acc
    (begin (serial-send (stacksize)) (tail-factorial (- n 1) (* acc n)))))

;(serial-send (tail-factorial 7 1))






(include "libraries/long.ms")






(define (lfactorial n)
  (if (l= n l0)
    l1
    (begin (serial-send (stacksize))(l* (lfactorial (l- n l1)) n))))

;(let ((it (lfactorial (long 0 11))))
;  (serial-send (hi it))
;  (serial-send (lo it)))





(define (tail-lfactorial n acc)
  (if (l= n l0)
    acc
    (begin (serial-send (stacksize)) (tail-lfactorial (l- n l1) (l* acc n)))))

(let ((it (tail-lfactorial (long 0 11) l1)))
  (serial-send (hi it))
  (serial-send (lo it)))



