;; ======================= Microscheme =======================
;; Library to read humidity and temperature from a DHT11 sensor
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

;; After receiving a start signal, the sensor sends 40 bits.
;; Each bit is sent as a 50 µs low pulse followed either by a 28 µs high pulse
;; for a 0 or by a 70 µs high pulse for a 1.
;; We first get an estimation of the size of the lows and highs for all the
;; bits, then we check for each pair wether the high is longer or shorter than
;; the low.

(define dht 8) ; Pin D8
(define dht-timeout 1000)
(define dht-low-cycles (make-vector 40))
(define dht-high-cycles (make-vector 40))
(define dht-data (make-vector 5))
(define dht-humidity 0)
(define dht-temperature 0)

(define (dht-init)
  ;; Activate internal pull-up for DHT line.
  (input dht)
  (high dht))

(define (dht-expect-pulse level count)
  (if (>= count dht-timeout)
      0
      (if (eq? level (high? dht))
          (dht-expect-pulse level (+ count 1))
          (+ 1 count)))) ; The +1 here is to differenciate from timeout case.

(define (dht-get-cycles i n)
  (if (< i n)
      (begin
        (vector-set! dht-low-cycles i (dht-expect-pulse #f 0))
        (vector-set! dht-high-cycles i (dht-expect-pulse #t 0))
        (dht-get-cycles (+ i 1) n))))

(define (dht-get-bits i n)
  (if (= i n)
      #t
      (let ((lc (vector-ref dht-low-cycles i))
            (hc (vector-ref dht-high-cycles i)))
        (if (or (zero? lc) (zero? hc))
            #f
            (let ((x (vector-ref dht-data (div i 8)))
                  (y (if (> hc lc) 1 0)))
              (vector-set! dht-data (div i 8) (+ (<< x) y))
              (dht-get-bits (+ i 1) n))))))

(define (dht-verify-checksum)
  (= (vector-ref dht-data 4)
     (& #xFF (+ (+ (vector-ref dht-data 0) (vector-ref dht-data 1))
                (+ (vector-ref dht-data 2) (vector-ref dht-data 3))))))

;; If everything goes well, dht-read returns #t and the dht-humidity and
;; dht-temperature variables contain the values sent by the sensor.
;; If there was an issue somewhere, dht-read returns #f.
(define (dht-read)
  (vector-set! dht-data 0 0)
  (vector-set! dht-data 1 0)
  (vector-set! dht-data 2 0)
  (vector-set! dht-data 3 0)
  (vector-set! dht-data 4 0)

  ;; Send a start signal by pulling the pin low for 18 ms and then pulling it
  ;; back up.
  (output dht)
  (low dht)
  (pause 18)
  (input dht)
  (high dht)
  (micropause 10)

  ;; The sensor starts the response with a 80 µs low and a 80 µs high.
  (if (and (> (dht-expect-pulse #f 0) 0)
           (> (dht-expect-pulse #t 0) 0))
      (begin
        (dht-get-cycles 0 40)
        (if (and (dht-get-bits 0 40) (dht-verify-checksum))
            (begin
              (set! dht-humidity (vector-ref dht-data 0))
              (set! dht-temperature (vector-ref dht-data 2))
              #t)
            #f))
      #f))
