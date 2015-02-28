;; Serial Communications Examples
;; microscheme.org

;; The available methods

;; (serial-init baud)
;;   Initialises the serial connection. Baud rate must be given in 100s of bits per second.
;;   For example, (serial-init 24) gives a rate of 2400 bps. (serial-init 10000) gives a
;;   rate of 1 Mbps, which is the maximum. A common 'default' rate is 9600 bps:

(serial-init 96)

;; (serial-write val)
;;   Writes the given value to the serial port. Only 1 byte is sent, so data types other
;;   than characters will be truncated.
;;   This can be combined with the higher-order-function 'for-each-vector' in order to
;;   print a string to the serial port:

(for-each-vector serial-write "Hello Serial World!")

;; (serial-available)
;;   Returns #t if any bytes are waiting in the serial RX buffer.

;; (serial-read)
;;   Returns 1 byte from the RX buffer. Note that this procedure will block indefinitely until
;;   a byte is recieved. We can use (serial-available) to check (poll) for incoming bytes,
;;   without 'locking up' the program.

;; The following example sets up a simple 'echo' system:

(define (polling-loop)
	(if (serial-available)
 		(serial-write (serial-read)))
 	(polling-loop))

(polling-loop)
