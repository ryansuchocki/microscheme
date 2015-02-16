;; @ardumont
;; microscheme.org

(define led-pin (output 13))

(define long-pulse 500)
(define short-pulse 250)

;; make the led blink
(define (blink time)
  (high led-pin)
  (pause time)
  (low led-pin)
  (pause time))

;; letter is a list of 0 and 1
(define (blink-letter letter)
  (map (lambda (signal)
         (blink (if (eq? 0 signal) short-pulse long-pulse)))
       letter))

(define (blink-sos)
  ;; s
  (blink-letter (list 0 0 0))
  ;; o
  (blink-letter (list 1 1 1))
  ;; s
  (blink-letter (list 0 0 0)))

;; some time after the firmware flashing
(pause 2000)

;; let the led call help
(blink-sos)

;; shutdown the led
(pause 0)
