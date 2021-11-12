;; ======================= Microscheme =======================
;; Musical stepper motor example
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(define mleft	(list 4 5 6 7))
(for-each output mleft)

(define (cycle m1 x)
	(or (null? m1)
		(begin
			(high (car m1))
			(micropause x)
			(low (car m1))
			(cycle (cdr m1) x))))

;; In theory, this is an A# scale:
(define scale (vector 1480 1319 1175 1109 988 880 784 740))
(define period (* 100 (vector-ref scale 0)))

(define (note x l)
	(for 0 (* l (div period x)) (lambda (_)
		(cycle mleft x))))

;; Twinkle twinkle, little star
(define notes   (list 0 0 4 4 5 5 4  3 3 2 2 1 1 0  4 4 3 3 2 2 1  4 4 3 3 2 2 1  0 0 4 4 5 5 4  3 3 2 2 1 1 0 ))
(define lengths (list 5 5 5 5 5 5 10 5 5 5 5 5 5 10 5 5 5 5 5 5 10 5 5 5 5 5 5 10 5 5 5 5 5 5 10 5 5 5 5 5 5 10))

(define (play x y)
	(note (vector-ref scale (car x)) (car y))
	(pause 100)
	(or (null? (cdr x)) (null? (cdr y)) 
		(play (cdr x) (cdr y))))

(play notes lengths)

