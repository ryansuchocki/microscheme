;; =============================== Microscheme ===============================
;; DHT sensor example for the Arduino UNO (or NANO)
;; (C) 2021 Ryan Suchocki, et al.
;; http://github.com/ryansuchocki/microscheme
;;

(include "libraries/ascii.ms")
(include "libraries/dht.ms")

(serial-init 96)
;; DHT connected on pin 8
(set! dht 8)
(dht-init)

(define (print-number x)
  (free!
   (for-each-vector serial-write (trim-leading-zeros (number->ascii x)))))

(define (loop)
  (if (dht-read)
      (begin
        (for-each-vector serial-write "Humidity: ")
        (print-number dht-humidity)
        (for-each-vector serial-write "%")
        (serial-write #\newline)
        (for-each-vector serial-write "Temperature: ")
        (print-number dht-temperature)
        (for-each-vector serial-write "°C")
        (serial-write #\newline))
      (begin
        (for-each-vector serial-write "Failed to get data from DHT")
        (serial-write #\newline)))
  (serial-write #\newline)
  (pause 10000)
  (loop))

(loop)
