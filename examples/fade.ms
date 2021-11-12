;; Fading LED example for the Arduino UNO (or NANO)
;; See https://docs.arduino.cc/built-in-examples/basics/Fade

;; Initialization to use the analog pins
(analog-init)

;; LED connected on pin 9
(define led 9)
(output led)

(define fade-amount 5)

(define (loop brightness add?)
  (if (and add? (> (+ brightness fade-amount) 255))
      (loop (- brightness fade-amount) #f)
      (if (and (not add?) (< brightness fade-amount))
          (loop (+ brightness fade-amount) #t)
          (begin
            (analog-write led brightness)
            (pause 30)
            (loop (if add?
                      (+ brightness fade-amount)
                      (- brightness fade-amount))
                  add?)))))

(loop 0 #t)
