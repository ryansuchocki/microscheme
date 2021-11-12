;; ======================= Microscheme =======================
;; LED blinking example
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(define led-pin (output 13))

(define (loop)
	(toggle led-pin)
	(pause 1000))

(forever loop)
