(define (long hi lo) (assert (number? hi)) (assert (number? lo)) (cons hi lo))
(define (set-long! lX hi lo) (assert (number? hi)) (assert (number? lo)) (set-car! lX hi) (set-cdr! lX lo) lX)
(define (clone lX) (long (car lX) (cdr lX)))
(define (copy lX lY) (set-car! lX (car lY)) (set-cdr! lX (cdr lY)))
(define (hi lX) (car lX))
(define (lo lX) (cdr lX))
(define (long? x) (and (pair? x) (number? (car x)) (number? (cdr x))))
(define l0 (long 0 0))
(define l1 (long 0 1))


(define (l= lX lY)
    (and (= (car lX) (car lY)) (= (cdr lX) (cdr lY))))

(define (l< lX lY)
    (or (< (car lX) (car lY))
        (and (= (car lX) (car lY)) (< (cdr lX) (cdr lY)))))

(define (l>= lX lY)
    (not (l< lX lY)))

(define (l> lX lY)
    (l< lY lX))

(define (l<= lX lY)
    (not (l< lY lX)))


(define (l++ lX lY)
    (if (>= (+ (cdr lX) (cdr lY)) 10000)
        (set-long! lX (+ (mod (+ (car lX) (car lY)) 10000) 1) (- (+ (cdr lX) (cdr lY)) 10000))
        (set-long! lX (mod (+ (car lX) (car lY)) 10000) (+ (cdr lX) (cdr lY)))))

(define (l-- lX lY)
    (if (l= lX l0)
        l0
        (if (> (cdr lY) (cdr lX))
            (set-long! lX (- (car lX) (+ (car lY) 1)) (- (+ (cdr lX) 10000) (cdr lY)))
            (set-long! lX (- (car lX) (car lY)) (- (cdr lX) (cdr lY)))))) 

(define (l+ lX lY) (l++ (clone lX) lY))
(define (l- lX lY) (l-- (clone lX) lY))
            
(define (softwarel* acc lX lY)
    (if (l= lY l0)
        l0
        (if (l= lY l1)
            acc
            (softwarel* (l++ acc lX) lX (l-- lY l1)))))

(define (l* lX lY) (softwarel* (clone lX) lX (clone lY)))
(define (l** lX lY) (copy lX (softwarel* (clone lX) lX (clone lY))))

(define (softwarel/ lX lY acc)
    (if (l< lX lY)
        acc
        (softwarel/ (l-- lX lY) lY (l++ acc l1))))

(define (l/ lX lY) (softwarel/ (clone lX) lY (clone l0)))
(define (l// lX lY) (copy lX (softwarel/ (clone lX) lX (clone lY))))

