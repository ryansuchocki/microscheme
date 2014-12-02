;; Microscheme primitives for other scheme implementations...
;; microscheme.org

;; This file defines microscheme-specific syntax/primitives, 
;; and emulates a set of digital I/O registers, so that you
;; can run Microscheme programs on other Scheme implementations
;; (For example, on your PC).

(define-syntax free!
  (syntax-rules ()
    ((free! body ...)
     (begin body ...))))

(define-syntax @if-model-uno
  (syntax-rules ()
    ((@if-model-uno body)
     body)))

(define-syntax @if-model-mega
  (syntax-rules ()
    ((@if-model-mega body)
     #f)))

(define-syntax @if-model-leo
  (syntax-rules ()
    ((@if-model-leo body)
     #f)))

(define ¬ not)
(define include load)
(define (div x y) (floor (/ x y)))
(define mod modulo)
(define (assert x) (if (not x) (error "ms" "assertion failed")))
(define (error) (error "ms" "custom-error"))
(define (stacksize) 0)
(define (heapsize) 0)
(define (pause x) (display "Pause for ") (display x) (display " milliseconds...") (display #\newline)) ;; TODO
(define (micropause x) (display "Pause for ") (display x) (display " microseconds...") (display #\newline)) ;; TODO
(define (serial-send x) (display "Serial: ") (display x) (display #\newline))
(define (char->number x) x) ;; TODO

(define digital-state #f)
(define set-digital-state #f)

(load "src/stdlib.ms")

(define ddr-state (vector #f #f #f #f #f #f #f #f #f #f #f #f #f))
(define pin-state (vector #f #f #f #f #f #f #f #f #f #f #f #f #f))

(define (showstate)
  (for 0 (vector-last ddr-state) (lambda (i)
    (if (vector-ref ddr-state i) 
      (if (vector-ref pin-state i)
        (display "H")
        (display "L"))
      (display "."))))
  (display #\newline))

 
(define (set-ddr apin val) (vector-set! ddr-state apin val) (showstate) apin)
(define (set-pin apin val) (vector-set! pin-state apin val) (showstate) apin)
(define (output? apin) (vector-ref ddr-state apin))
(define (high? apin) (vector-ref pin-state apin))

(display "Microscheme emulation ready...")
#t