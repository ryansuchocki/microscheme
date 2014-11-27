(define (fp whole frac) (assert (number? hi)) (assert (number? lo)) (cons whole frac))
(define (set-fp! fpX whole frac) (assert (number? whole)) (assert (number? frac)) (set-car! fpX whole) (set-cdr! fpX frac) fpX)
(define (clone fpX) (fp (car fpX) (cdr fpX)))
(define (copy fpX fpY) (set-car! fpX (car fpY)) (set-cdr fpX (cdr fpY)))
(define (whole fp) (car fp))
(define (frac fp) (cdr fp))
(define (fp? x) (and (pair? x) (number? (car x)) (number? (cdr x))))
(define fp0 (fp 0 0))
(define fp1 (fp 1 0))


(define (fp= fpX fpY)
    (and (= (car fpX) (car fpY)) (= (cdr fpX) (cdr fpY))))

(define (fp< fpX fpY)
    (or (< (car fpX) (car fpY))
        (and (= (car fpX) (car fpY)) (< (cdr fpX) (cdr fpY)))))

(define (fp>= fpX fpY)
    (not (f< fpX fpY)))

(define (fp> fpX fpY)
    (f< fpY fpX))

(define (fp<= fpX fpY)
    (not (f< fpY fpX)))


(define (fp++ fpX fpY)
    (if (>= (+ (cdr fpX) (cdr fpY)) 10000)
        (set-long! fpX (+ (mod (+ (car fpX) (car fpY)) 10000) 1) (- (+ (cdr fpX) (cdr fpY)) 10000))
        (set-long! fpX (mod (+ (car fpX) (car fpY)) 10000) (+ (cdr fpX) (cdr fpY)))))

(define (fp-- fpX fpY)
    (if (l= fpX l0)
        l0
        (if (> (cdr fpY) (cdr fpX))
            (set-long! fpX (- (car fpX) (+ (car fpY) 1)) (- (+ (cdr fpX) 10000) (cdr fpY)))
            (set-long! fpX (- (car fpX) (car fpY)) (- (cdr fpX) (cdr fpY)))))) 

(define (fp+ fpX fpY) (fp++ (clone fpX) fpY))
(define (fp- fpX fpY) (fp-- (clone fpX) fpY))



;; The following probably need work:


(define (fp* fpX fpY)
    (let ((fr (+ (div (* (cdr fpX) (cdr fpY)) 10000) (* (car fpX) (cdr fpY)) (* (cdr fpX) (car fpY)))))
        (fp (+ (* (car fpX) (car fpY)) (div fr 10000)) (mod fr 10000))))



(define (fp/aux fpX fpY f)
    (if (f< fpX fpY)
        (f fpX fpY)
        (f+ (fp 1 0) (fp/aux (f- fpX fpY) fpY f))))

(define (shiftL fpX)
    (fp (cdr fpX) 0))
(define (shiftR fpX)
    (fp 0 (car fpX)))

(define (fp/ fpX fpY)
    (fp/aux fpX fpY (lambda (x y) (shiftR (fp/aux (shiftL x) y (lambda (u v) 
    (if (f< u (f* (fp 0 5000) v)) (fp 0 0) (fp 1 0))
    ))))))
