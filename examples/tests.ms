
(define mleft	(list 29 31 33 35))
(for-each output mleft)

(define (cycle m1 x)
	(or (null? m1)
		(begin
			(high (car m1))
			(micropause x)
			(low (car m1))
			(cycle (cdr m1) x))))
			
(define (loop)
	(cycle mleft 3000))

(forever loop)



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