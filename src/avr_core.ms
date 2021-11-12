;; The Microscheme AVR Core Library
;; microscheme.org


;; Serial communications

(define (serial-init baud)
	(div (- 10000 (>> baud)) baud)

	; Set Baud Rate registers
	(asm "STS	UBRR0H,	CRSh"
	     "STS	UBRR0L,	CRSl")

	; Set control registers
	(asm "LDI GP1,	(1<<RXEN0)|(1<<TXEN0)"
	     "STS UCSR0B,	GP1"))

(define (serial-write x)
	x
	(asm "util_serial_send:"
	     "  PUSH GP1"
	     "  util_serial_send_wait:"
	     "    LDS GP1, UCSR0A"
	     "    SBRS GP1, UDRE0"
	     "    RJMP util_serial_send_wait"
	     "  STS	UDR0, CRSl"
	     "  POP GP1"))

(define (serial-available)
	#f
	(asm "LDS GP1, UCSR0A"
	     "SBRC GP1, RXC0")
	#t)

(define (serial-read)
	#\a
	(asm "util_serial_receive:"
		 "	PUSH GP1"
		 "  util_serial_receive_wait:"
		 "    LDS GP1, UCSR0A"
	     "    SBRS GP1, RXC0"
	     "    RJMP util_serial_receive_wait"
	     "  LDS CRSl, UDR0"
	     "  POP GP1"))


;; Digital Input/Output

(define arduino-ports)
(define arduino-pins)

(@if-model "MEGA"
  (begin
    ;; E0 E1 E4 E5 G5 E3 H3 H4  (D0 - D7)
    ;; H5 H6 B4 B5 B6 B7 J1 J0  (D8 - D15)
    ;; H1 H0 D3 D2 D1 D0 A0 A1  (D16 - D23)
    ;; A2 A3 A4 A5 A6 A7 C7 C6  (D24 - D31)
    ;; C5 C4 C3 C2 C1 C0 D7 G2  (D32 - D39)
    ;; G1 G0 L7 L6 L5 L4 L3 L2  (D40 - D47)
    ;; L1 L0 B3 B2 B1 B0        (D48 - D53)
    ;; F0 F1 F2 F3 F4 F5 F6 F7  (A0 - A7)
    ;; K0 K1 K2 K3 K4 K5 K6 K7  (A8 - A15)
    (set! arduino-ports (vector #x2C #x2C #x2C #x2C #x32 #x2C #x100 #x100
                                #x100 #x100 #x23 #x23 #x23 #x23 #x103 #x103
                                #x100 #x100 #x29 #x29 #x29 #x29 #x20 #x20
                                #x20 #x20 #x20 #x20 #x20 #x20 #x26 #x26
                                #x26 #x26 #x26 #x26 #x26 #x26 #x29 #x32
                                #x32 #x32 #x109 #x109 #x109 #x109 #x109 #x109
                                #x109 #x109 #x23 #x23 #x23 #x23
                                #x2F #x2F #x2F #x2F #x2F #x2F #x2F #x2F
                                #x106 #x106 #x106 #x106 #x106 #x106 #x106 #x106))
    (set! arduino-pins (vector 1 2 16 32 32 8 8 16
                               32 64 16 32 64 128 2 1
                               2 1 8 4 2 1 1 2
                               4 8 16 32 64 128 128 64
                               32 16 8 4 2 1 128 4
                               2 1 128 64 32 16 8 4
                               2 1 8 4 2 1
                               1 2 4 8 16 32 64 128
                               1 2 4 8 16 32 64 128))))

(@if-model "UNO"
  (begin
    ;; D0 D1 D2 D3 D4 D5 D6 D7  (D0 - D7)
    ;; B0 B1 B2 B3 B4 B5        (D8 - D13)
    ;; C0 C1 C2 C3 C4 C5        (A0 - A5)
    (set! arduino-ports (vector #x29 #x29 #x29 #x29 #x29 #x29 #x29 #x29
                                #x23 #x23 #x23 #x23 #x23 #x23
                                #x26 #x26 #x26 #x26 #x26 #x26))
    (set! arduino-pins (vector 1 2 4 8 16 32 64 128
                               1 2 4 8 16 32
                               1 2 4 8 16 32))))

(@if-model "LEO"
  (begin
    ;; D2 D3 D1 D0 D4 C6 D7 E6  (D0 - D7)
    ;; B4 B5 B6 B7 D6 C7        (D8 - D13)
    ;; B3 B1 B2 B0              (MISO SCK MOSI SS)
    ;; F7 F6 F5 F4 F1 F0        (A0 - A5)
    (set! arduino-ports (vector #x29 #x29 #x29 #x29 #x29 #x26 #x29 #x2C
                                #x23 #x23 #x23 #x23 #x29 #x26
                                #x23 #x23 #x23 #x23
                                #x2f #x2f #x2f #x2f #x2f #x2f))
    (set! arduino-pins (vector 4 8 2 1 16 64 128 64
                               16 32 64 128 64 128
                               8 2 4 1
                               128 64 32 16 2 1))))

(define (set-ddr apin val)
	(set-digital-state (+ 1 (vector-ref arduino-ports apin)) (vector-ref arduino-pins apin) val)
	apin)

(define (set-pin apin val)
	(set-digital-state (+ 2 (vector-ref arduino-ports apin)) (vector-ref arduino-pins apin) val)
	apin)

(define (output? apin)
	(digital-state (+ 1 (vector-ref arduino-ports apin)) (vector-ref arduino-pins apin)))
	
(define (high? apin)
	(digital-state (vector-ref arduino-ports apin) (vector-ref arduino-pins apin)))

(define (input p)	(set-ddr p #f))
(define (output p)	(set-ddr p #t))
(define (high p)	(set-pin p #t))
(define (low p)		(set-pin p #f))

(define (input? p)	(¬ (output? p)))
(define (low? p)	(¬ (high? p)))

(define (toggle p)	(set-pin p (low? p)))


;; Analog Input/Output

(define arduino-pin-to-adc)
(define arduino-pin-to-timer)
(define arduino-timers-tccr)
(define arduino-timers-ocr)
(define arduino-timers-com1)
(define arduino-timers-pwm-mode)
(define arduino-timers-prescaler)

(@if-model "MEGA"
  (begin
    ;; A0 on pin 54
    (set! arduino-pin-to-adc (lambda (p) (if (< p 54) #f (- p 54))))

    ;; Timers: 0A on pin 13, 0B on pin 4,
    ;;         1A on pin 11, 1B on pin 12,
    ;;         2A on pin 10, 2B on pin 9
    (set! arduino-pin-to-timer (lambda (p)
                                 (if (= p 13)
                                     0
                                     (if (= p 4)
                                         1
                                         (if (= p 11)
                                             2
                                             (if (= p 12)
                                                 3
                                                 (if (= p 10)
                                                     4
                                                     (if (= p 9)
                                                         5
                                                         #f))))))))
    (set! arduino-timers-tccr (vector #x44 #x44 #x80 #x80 #xB0 #xB0))
    (set! arduino-timers-ocr (vector #x47 #x48 #x88 #x8A #xB3 #xB4))
    (set! arduino-timers-com1 (vector 128 32 128 32 128 32))
    ;; Use fast PWM for timer 0 and phase-correct PWM for timers 1 and 2
    (set! arduino-timers-pwm-mode (vector 3 1 1))
    ;; Use a prescaler of 64 for all timers
    (set! arduino-timers-prescaler (vector 3 3 4))))

(@if-model "UNO"
  (begin
    ;; A0 on pin 14
    (set! arduino-pin-to-adc (lambda (p) (if (< p 14) #f (- p 14))))

    ;; Timers: 0A on pin 6, 0B on pin 5,
    ;;         1A on pin 9, 1B on pin 10,
    ;;         2A on pin 11, 2B on pin 3
    (set! arduino-pin-to-timer (lambda (p)
                                 (if (= p 6)
                                     0
                                     (if (= p 5)
                                         1
                                         (if (= p 9)
                                             2
                                             (if (= p 10)
                                                 3
                                                 (if (= p 11)
                                                     4
                                                     (if (= p 3)
                                                         5
                                                         #f))))))))
    (set! arduino-timers-tccr (vector #x44 #x44 #x80 #x80 #xB0 #xB0))
    (set! arduino-timers-ocr (vector #x47 #x48 #x88 #x8A #xB3 #xB4))
    (set! arduino-timers-com1 (vector 128 32 128 32 128 32))
    ;; Use fast PWM for timer 0 and phase-correct PWM for timers 1 and 2
    (set! arduino-timers-pwm-mode (vector 3 1 1))
    ;; Use a prescaler of 64 for all timers
    (set! arduino-timers-prescaler (vector 3 3 4))))

(@if-model "LEO"
  (begin
    ;; A0 on pin 18, but ADCs not in regular order
    (set! arduino-pin-to-adc (lambda (p)
                               (if (= p 18)
                                   7
                                   (if (= p 19)
                                       6
                                       (if (= p 20)
                                           5
                                           (if (= p 21)
                                               4
                                               (if (= p 22)
                                                   1
                                                   (if (= p 23)
                                                       0
                                                       #f))))))))

    ;; Timers: 0A on pin 11, 0B on pin 3,
    ;;         1A on pin 9, 1B on pin 10,
    ;;         3A on pin 5
    (set! arduino-pin-to-timer (lambda (p)
                                 (if (= p 11)
                                     0
                                     (if (= p 3)
                                         1
                                         (if (= p 9)
                                             2
                                             (if (= p 10)
                                                 3
                                                 (if (= p 5)
                                                     4
                                                     #f)))))))
    (set! arduino-timers-tccr (vector #x44 #x44 #x80 #x80 #x90))
    (set! arduino-timers-ocr (vector #x47 #x48 #x88 #x8A #x98))
    (set! arduino-timers-com1 (vector 128 32 128 32 128))
    ;; Use fast PWM for timer 0 and phase-correct PWM for timers 1 and 3
    (set! arduino-timers-pwm-mode (vector 3 1 1))
    ;; Use a prescaler of 64 for all timers
    (set! arduino-timers-prescaler (vector 3 3 3))))

(define (initialize-adc)
  ;; Enable ADC with a prescaler of 128
  (asm "PUSH GP6"
       "LDI GP6, 0b10000111"
       "STS ADCSRA, GP6"
       "POP GP6"))

(define (initialize-pwm i)
  ;; Set timer i for PWM
  (let ((tccr (vector-ref arduino-timers-tccr (* 2 i))))
    (set-register-state tccr (vector-ref arduino-timers-pwm-mode i))
    (set-register-state (+ 1 tccr) (vector-ref arduino-timers-prescaler i))))

(define (analog-init)
  (initialize-adc)
  (for 0 (- (vector-length arduino-timers-pwm-mode) 1) initialize-pwm))

(define (analog-read p)
  (let ((adc (arduino-pin-to-adc p)))
    ;; If pin doesn't have ADC (adc is #f), use digital instead
    (if (eq? adc #f)
        (if (high? p) 1023 0)
        (begin
          ;; Start ADC with AVcc voltage reference
          (asm "PUSH GP1")
          adc
          (asm "ORI CRSl, (1 << REFS0)"
               "STS ADMUX, CRSl"
               "LDS GP1, ADCSRA"
               "ORI GP1, (1 << ADSC)"
               "STS ADCSRA, GP1")
          ;; Wait until ADC has finished
          (asm "util_adc_wait:"
               "  LDS GP1, ADCSRA"
               "  SBRC GP1, ADSC"
               "  RJMP util_adc_wait")
          (asm "POP GP1")
          ;; Read result
          (asm "LDS CRSl, ADCL"
               "LDS CRSh, ADCH")))))

(define (analog-write p n)
  (let ((timer (arduino-pin-to-timer p)))
    ;; If pin doesn't have PWM (timer is #f), use digital instead
    (if (eq? timer #f)
        (if (< n 127) (low p) (high p))
        (begin
          ;; Connect PWM to pin
          (set-digital-state (vector-ref arduino-timers-tccr timer)
                             (vector-ref arduino-timers-com1 timer)
                             #t)
          ;; Activate PWM
          (set-register-state (vector-ref arduino-timers-ocr timer) n))))
  n)
