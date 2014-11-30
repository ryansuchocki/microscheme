;; Boilerplate stuff for the Arduino Uno
;; CPU: ATMega168/328

.EQU	IS_MODEL_UNO,	1
.EQU	IS_MODEL_MEGA,	0
.EQU	IS_MODEL_LEO,	0

;; Stack Pointers:

.EQU	SPl,	0x3D
.EQU	SPh,	0x3E

;; RAM Helpers
.EQU	RAM,	0x100
.EQU	RAMEND,	0x08FF

;; Short-Range Data Ports:

.EQU	PINB,	0x03
.EQU	DDRB,	0x04
.EQU	PORTB,	0x05
.EQU	PINC,	0x06
.EQU	DDRC,	0x07
.EQU	PORTC,	0x08
.EQU	PIND,	0x09
.EQU	DDRD,	0x0A
.EQU	PORTD,	0x0B

;; Data-Port Memory Map Addresses
.EQU	mPINB,	0x23
.EQU	mDDRB,	0x24
.EQU	mPORTB,	0x25
.EQU	mPINC,	0x26
.EQU	mDDRC,	0x27
.EQU	mPORTC,	0x28
.EQU	mPIND,	0x29
.EQU	mDDRD,	0x2A
.EQU	mPORTD,	0x2B


;; 16-bit counting registers, of which XYZ are 
;; are memory address registers.
.EQU	WL,	0x18
.EQU	WH,	0x19
.EQU	XL,	0x1A
.EQU	XH,	0x1B
.EQU	YL,	0x1C
.EQU	YH,	0x1D
.EQU 	ZL,	0x1E
.EQU	ZH,	0x1F







.EQU	PORT13,	PORTB
.EQU	DDR13,	DDRB
.EQU	PIN13,	PINB
.EQU	P13,	5

.EQU	mPORT13,	mPORTB
.EQU	mDDR13,	mDDRB
.EQU	mPIN13,	mPINB
.EQU	mP13,	0b00100000






.EQU	UDR0,	0xC6
.EQU	UBRR0H,	0xC5
.EQU	UBRR0L,	0xC4
.EQU	UCSR0C,	0xC2
.EQU	UCSR0B,	0xC1
.EQU	UCSR0A,	0xC0

.EQU	UDRE0,	5		; Transmit Buffer Empty
.EQU	TXC0,	6		; TX Complete
.EQU	RXC0,	7		; RX Complete

.EQU	TXENm,	0x08;
.EQU	RXENm,	0x10;

.EQU	BAUD_9600, 103



