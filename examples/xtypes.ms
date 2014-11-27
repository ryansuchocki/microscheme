(include "libraries/long.ms")

(define fp long)
(define set-fp! set-long!)
(define (whole fp) (car fp))
(define (frac fp) (cdr fp))
(define fp? long?)
(define fp0 long0)
(define fp1 (fp 1 0))

(define fp= l=)
(define fp< l<)
(define fp>= l>=)
(define fp> l>)
(define fp<= l<=)


(define fp++ l++)
(define fp+ l+)
(define fp-- l--)
(define fp- l-)



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
