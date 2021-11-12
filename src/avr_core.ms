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
		(set! arduino-ports	(vector #x2C	#x2C	#x2C	#x2C	#x32	#x2C	#x100	#x100
									#x100	#x100	#x23	#x23	#x23	#x23	#x109	#x109
									#x100	#x100	#x26	#x26	#x26	#x26	#x20	#x20	
									#x20	#x20	#x20	#x20	#x20	#x20	#x26	#x26
									#x26	#x26	#x26	#x26	#x26	#x26	#x26	#x32
									#x32	#x32	#x109	#x109	#x109	#x109	#x109	#x109
									#x109	#x109	#x23	#x23	#x23	#x23))
		(set! arduino-pins	(vector 1 2 16 32 32 8 8 16 32 64 16 32 64 128 2 1 2 1 8 4 2 1 1 2 4 
									8 16 32 64 128 128 64 32 16 8 4 2 1 128 4 2 1 128 64 32 16 8 
									4 2 1 8 4 2 1))))

(@if-model "UNO"
	(begin
		(set! arduino-ports	(vector #x29 #x29 #x29 #x29 #x29 #x29 #x29 #x29 #x23 #x23 #x23 #x23 #x23 #x23))
		(set! arduino-pins	(vector 1 2 4 8 16 32 64 128 1 2 4 8 16 32))))

(@if-model "LEO"
	;; D2 D3 D1 D0 D4 C6 D7 E6 B4 B5 B6 B7 D6 C7 B3 B1 B2 B3 F7 F6 F5 F4 F1 F0
	(begin
		(set! arduino-ports	(vector #x29 #x29 #x29 #x29 #x29 #x26 #x29 #x2C
									#x23 #x23 #x23 #x23 #x29 #x26 #x23 #x23
									#x23 #x23 #x2f #x2f #x2f #x2f #x2f #x2f))
		(set! arduino-pins	(vector 4 8 2 1 16 64 128 64 16 32 64 128 64 128
									8 2 4 1 128 64 32 16 2 1))))

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
