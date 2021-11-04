;; 
;; microscheme.org

;; Primitives

(define (eq? x y) (eq? x y))
(define (= x y) (= x y))
(define (> x y) (> x y))
(define (>= x y) (>= x y))
(define (< x y) (< x y))
(define (<= x y) (<= x y))
(define (not x) (not x))
(define (¬ x) (¬ x))

(define (+ x y) (+ x y))
(define (* x y) (* x y))
(define (- x y) (- x y))
(define (div x y) (div x y))
(define (mod x y) (mod x y))
(define (zero? x) (zero? x))

(define (number? x) (number? x))
(define (pair? x) (pair? x))
(define (vector? x) (vector? x))
(define (procedure? x) (procedure? x))
(define (char? x) (char? x))
(define (boolean? x) (boolean? x))
(define (null? x) (null? x))

(define (cons x y) (cons x y))
(define (car x) (car x))
(define (cdr x) (cdr x))
(define (set-car! x y) (set-car! x y))
(define (set-cdr! x y) (set-cdr! x y))

(define (vector-length x) (vector-length x))
(define (vector-ref x y) (vector-ref x y))
(define (vector-set! x y z) (vector-set! x y z))
(define (make-vector x) (make-vector x))

(define (assert x) (assert x))
(define (error) (error))
(define (stacksize) (stacksize))
(define (heapsize) (heapsize))
(define (pause x) (pause x))
(define (micropause x) (micropause x))

(define (digital-state x y) (digital-state x y))
(define (set-digital-state x y z) (set-digital-state x y z))
(define (set-register-state x y) (set-register-state x y))
(define (char->number x) (char->number x))
(define (number->char x) (number->char x))
(define (arity x) (arity x))

(define (>> x) (>> x))
(define (<< x) (<< x))
