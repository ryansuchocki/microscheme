(serial-send (heapsize))

(define thelist (list 1 2 3 4))

(serial-send (heapsize))

(define revlist (reverse thelist))

(serial-send (heapsize))

(for-each serial-send revlist)

(serial-send (heapsize))



; (define mleft	(list 29 31 33 35))
; (for-each output mleft)

; (define (pulse s1 s2 s3 s4)
; 	(set-pin 29 s1)
; 	(set-pin 31 s3)
; 	(set-pin 33 s2)
; 	(set-pin 35 s4)
; 	(pause 100))
			
; (define (loop)
; 	(pulse #f #t #f #t)
; 	(pulse #f #t #t #f)
; 	(pulse #t #f #t #f)
; 	(pulse #t #f #f #t))

; (forever loop)

; (serial-send +)

;(define llst (list (list 1 2 3) (list 1 2 3) (vector ) "hello" +))
;(define rlst (list (list 1 () 3) (list 1 2 3) "" "h2ello" +))


;(for-each
;	(lambda (x)
;		(if (equal? (car x) (cdr x))
;			(write #\T)
;			(write #\F)))
;	(zip llst rlst))

;(;include "libraries/list.ms")
;(include "libraries/ascii.ms")

;(writestring (vector-concat "Hello " "World"))

;(writenum (foldl + 0 (list 1 2 3 4 5 6 7 8 9 10)))

;(print (list (cons 2 #\R) "hi" (vector #f +)))