;; A microscheme library for controlling MAX7219 and MAX7221 chips.
;; These are serially-interfaced 8x8 multiplex drivers, commonly used
;; for LED arrays and 7-segment displays.

;; ==================== Internal procedures ==================== 
;;             (These should not be called directly)

(define (shift-out-bits data-pin clock-pin data n)
	(set-pin data-pin (¬ (number? data)))
	(low (high clock-pin))
	(or (zero? n)
		(shift-out-bits data-pin clock-pin (<< data) (- n 1))))

(define (noops data-pin clock-pin n)
	(or (zero? n)
		(begin
			(shift-out-bits data-pin clock-pin #x0000 15)
			(noops data-pin clock-pin (- n 1)))))

(define (shift-out chip index data)
	(let ((data-pin (vector-ref chip 0))
		  (clock-pin (vector-ref chip 1))
		  (latch-pin (vector-ref chip 2))
		  (num (vector-ref chip 3)))
		(low latch-pin)
			(noops data-pin clock-pin (- (- num index) 1))
			(shift-out-bits data-pin clock-pin data 15)
			(noops data-pin clock-pin index)
		(high latch-pin)))

;; ==================== External procedures ==================== 
;;              (These should be called directly)

;; Each chip features one data-in pin and one data-out pin, so that
;; up to 8 chips can be cascaded together, sharing a single data line.
;; Each cascade of chips must be initialised using def-max7. The result
;; is an object used to reference a particular cascade of chips, when it
;; comes to sending data.

(define (def-max7 data-pin clock-pin latch-pin num)
	(vector 
		(low (output data-pin))
		(low (output clock-pin))
		(high (output latch-pin))
		num))

(define (digit chip index dig val)	(shift-out chip index (+ (* dig #x100) val)))
(define (decode chip index m)		(shift-out chip index (+ #x0900 m)))
(define (intensity chip index x)	(shift-out chip index (+ #x0A00 x)))
(define (scan-limit chip index n)	(shift-out chip index (+ #x0B00 n)))
(define (show chip index state)		(shift-out chip index (if state #x0C01 #x0C00)))
(define (test chip index state)		(shift-out chip index (if state #x0F01 #x0F00)))


;; ======================= Example Usage ======================= 

; (include "libraries/max7.ms")

; We have 2 max7219 chips cascaded together, on pins 10, 11 and 12
; (define led (def-max7 10 11 12 2))
; ... connected to a 16-digit 7-segment display!

; We set both chips to decode-mode on all digits:
; So that we can send numeric characters directly (in BCD)
; (decode led 0 #xFF)
; (decode led 1 #xFF)

; Set the intensity to maximum on both chips:
; (intensity led 0 #x0F)
; (intensity led 1 #x0F)

; Enable all digits on both chips:
; (scan-limit led 0 #x07)
; (scan-limit led 1 #x07)

; Make sure both chips are out of 'shutdown' mode:
; (show led 0 #t)
; (show led 1 #t)

; Now we display the number '0102030405060708'

; (digit led 0 1 0)
; (digit led 0 2 1)
; (digit led 0 3 0)
; (digit led 0 4 2)
; (digit led 0 5 0)
; (digit led 0 6 3)
; (digit led 0 7 0)
; (digit led 0 8 4)
; (digit led 1 1 0)
; (digit led 1 2 5)
; (digit led 1 3 0)
; (digit led 1 4 6)
; (digit led 1 5 0)
; (digit led 1 6 7)
; (digit led 1 7 0)
; (digit led 1 8 8)
