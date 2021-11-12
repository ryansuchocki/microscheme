;; ======================= Microscheme =======================
;; The Standard Library
;; (C) 2014-2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;


;; Looping constructs

(define (forever f)
	(f)
	(forever f))

(define (vector-last vect)
	(- (vector-length vect) 1))

(define (for a z f)
	(if (<= a z)
		(begin
			(f a)
			(for (+ a 1) z f))))

;; Rich equivalence predicate

(define equal? #f)

(define (vector-equal-aux test? X Y N L)
	(if (= N L)
		#t
		(if (test? (vector-ref X N) (vector-ref Y N))
			(vector-equal-aux test? X Y (+ N 1) L)
			#f)))

(define equal? (lambda (X Y)
	(or
		(eq? X Y)
		(and 
			(pair? X)
			(pair? Y)
			(equal? (car X) (car Y))
			(equal? (cdr X) (cdr Y)))
		(and
			(vector? X)
			(vector? Y)
			(= (vector-length X) (vector-length Y))
			(vector-equal-aux equal? X Y 0 (vector-length X))))))

(define (all-vector-aux test X N L)
	(if (= N L)
		#t
		(if (test (vector-ref X N))
			(all-vector-aux test X (+ N 1) L)
			#f)))

(define (all-vector test vect)
	(all-vector-aux test vect 0 (vector-length vect)))

(define (string? str)
	(and
		(vector? str)
		(all-vector char? str)))

(define (list? x)
	(or (null? x)
		(and (pair? x) 
			(list? (cdr x)))))


;;Iterate:

(define ($ p n x)
	(or (zero? n)
		($ p n (p x))))


;; List Processing

(define (reverse-aux lst acc)
	(if (null? lst)
		acc
		(reverse-aux (cdr lst) (cons (car lst) acc))))

(define (reverse lst)
	(reverse-aux lst '()))

(define (append l m)
	(if (null? l) m
		(cons (car l)
			(append (cdr l) m))))

(define (map-aux proc lst acc)
	(if (null? lst)
		acc
		(map-aux proc (cdr lst) (cons (proc (car lst)) acc))))

(define (map proc lst)
	(reverse-aux (map-aux proc lst '()) '()))

(define (map-2-aux proc lst1 lst2 acc)
	(if (or (null? lst1) (null? lst2))
		acc
		(map-2-aux proc (cdr lst1) (cdr lst2) (cons (proc (car lst1) (car lst2)) acc))))

(define (map-2 proc lst1 lst2)
	(reverse-aux (map-2-aux proc lst1 lst2 '()) '()))

(define (zip x y)
	(map-2 cons x y))

(define (length-aux lst acc)
	(if (null? lst)
		acc
		(length-aux (cdr lst) (+ acc 1))))

(define (length lst)
	(length-aux lst 0))

(define (fold-right f z xs)
	(if (null? xs)
		z
		(f (car xs) (fold-right f z (cdr xs)))))

(define (fold f z xs)
	(if (null? xs)
		z
		(fold f (f z (car xs)) (cdr xs))))

(define (for-each proc lst)
	(if (null? lst)
		#t
		(begin
			(proc (car lst))
			(for-each proc (cdr lst)))))
		
(define (all test lst)
	(or (null? lst)
		(and (test (car lst)) 
			(all test (cdr lst)))))

(define (for-both p x)
	(p (car x))
	(p (cdr x)))

(define (member v lst)
	(if (null? lst)
		#f
		(if (equal? v (car lst))
			lst
			(member v (cdr lst)))))


;; Apply!

(define (apply fnc lst)
	(assert (procedure? fnc))
	(assert (list? lst))
	(asm "PUSH AFPh") (asm "PUSH AFPl")
	(asm "PUSH CCPh") (asm "PUSH CCPl")
	(asm "LDI GP1, hi8(pm(sp_apply_ret))")
	(asm "PUSH GP1")
	(asm "LDI GP1, lo8(pm(sp_apply_ret))")
	(asm "PUSH GP1")
	lst
	(asm "MOVW CCPl, CRSl")
	(asm "sp_loop_begin:")
		(asm "MOVW CRSl, CCPl")
		(asm "CALL inline_car")
		(asm "PUSH CRSl") (asm "PUSH CRSh")
		(asm "MOVW CRSl, CCPl")
		(asm "CALL inline_cdr")
		(if (not (null? (asm "MOVW CCPl, CRSl")))
			(asm "RJMP sp_loop_begin"))
	(length lst)
	(asm "MOV PCR, CRSl")
	fnc
	(asm "IN AFPl, SPl") (asm "IN AFPh, SPh")
	(asm "MOVW GP5, AFPl")
	(asm "JMP proc_call")
	(asm "sp_apply_ret:")
	(asm "POP CCPl") (asm "POP CCPh")
	(asm "POP AFPl") (asm "POP AFPh"))


;; Vector Processing

(define (fevstep proc vect i n)
	(if (< i n) 
		(begin
			(proc (vector-ref vect i))
			(fevstep proc vect (+ i 1) n))))

(define (for-each-vector proc vect)
	(fevstep proc vect 0 (vector-length vect)))

(define (fevrstep proc vect i)
	(proc (vector-ref vect i))
	(if (> i 0)
		(fevrstep proc vect (- i 1))))

(define (for-each-vector-reverse proc vect)
	(fevrstep proc vect (vector-last vect)))

(define (vlstep vect i n acc)
	(if (< i n) 
		(vlstep vect (+ i 1) n (cons (vector-ref vect i) acc))
		acc))

(define (make-writer vect index)
	(lambda (value)
		(vector-set! vect index value)
		(set! index (+ index 1))))

(define (vector-concat left right)
	(let ((destination (make-vector (+ (vector-length left) (vector-length right)))))
		(free!
			(let ((writer (make-writer destination 0)))
				(for-each-vector writer left)
				(for-each-vector writer right)
				destination))))

;; for backwards-compatibility, this is the old version
(define (vector-copy src dest src-start src-finish dest-start)
	(if (> src-start src-finish)
		dest
		(begin
			(vector-set! dest dest-start (vector-ref src src-start))
			(vector-copy src dest (+ src-start 1) src-finish (+ dest-start 1)))))

;; this is the SRFI-43-compliant version
(define (vector-copy! dest dest-start src src-start src-finish)
	(if (> src-start src-finish)
		dest
		(begin
			(vector-set! dest dest-start (vector-ref src src-start))
			(vector-copy src dest (+ src-start 1) src-finish (+ dest-start 1)))))

(define (sub-vector vect start finish)
	(vector-copy vect (make-vector (+ (- finish start) 1)) start finish 0))

(define (vector-first-step vect test start)
	(if (or (>= start (vector-length vect)) (test (vector-ref vect start))) 
		start
		(vector-first-step vect test (+ start 1))))

(define (vector-first vect test)
	(vector-first-step vect test 0))

(define (vector->list vect)
	(reverse (vlstep vect 0 (vector-length vect) '())))

(define (list->vector lst)
	(let ((vect (make-vector (length lst))))
		(free!
			(for-each (make-writer vect) lst))))
