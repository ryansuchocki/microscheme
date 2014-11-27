;; Boilerplate stuff for the Arduino Mega (2560)
;; CPU: ATMega2560

.EQU	IS_MODEL_MEGA,	1
.EQU	IS_MODEL_UNO,	0


;; Stack Pointers:

.EQU	SPl,	0x3D
.EQU	SPh,	0x3E

;; RAM Helpers
.EQU	RAM,	0x200
.EQU	RAMEND,	0x21FF

;; Short-Range Data Ports:

.EQU	PINA,	0x00
.EQU	DDRA,	0x01
.EQU	PORTA,	0x02
.EQU	PINB,	0x03
.EQU	DDRB,	0x04
.EQU	PORTB,	0x05
.EQU	PINC,	0x06
.EQU	DDRC,	0x07
.EQU	PORTC,	0x08
.EQU	PIND,	0x09
.EQU	DDRD,	0x0A
.EQU	PORTD,	0x0B
.EQU	PINE,	0x0C
.EQU	DDRE,	0x0D
.EQU	PORTE,	0x0E
.EQU	PINF,	0x0F
.EQU	DDRF,	0x10
.EQU	PORTF,	0x11
.EQU	PING,	0x12
.EQU	DDRG,	0x13
.EQU	PORTG,	0x14

;; Data-Port Memory Map Addresses
.EQU	mPINA,	0x20
.EQU	mDDRA,	0x21
.EQU	mPORTA,	0x22
.EQU	mPINB,	0x23
.EQU	mDDRB,	0x24
.EQU	mPORTB,	0x25
.EQU	mPINC,	0x26
.EQU	mDDRC,	0x27
.EQU	mPORTC,	0x28
.EQU	mPIND,	0x29
.EQU	mDDRD,	0x2A
.EQU	mPORTD,	0x2B
.EQU	mPINE,	0x2C
.EQU	mDDRE,	0x2D
.EQU	mPORTE,	0x2E
.EQU	mPINF,	0x2F
.EQU	mDDRF,	0x30
.EQU	mPORTF,	0x31
.EQU	mPING,	0x32
.EQU	mDDRG,	0x33
.EQU	mPORTG,	0x34
.EQU	mPINH,	0x100
.EQU	mDDRH,	0x101
.EQU	mPORTH,	0x102
.EQU	mPINJ,	0x103
.EQU	mDDRJ,	0x104
.EQU	mPORTJ,	0x105
.EQU	mPINK,	0x106
.EQU	mDDRK,	0x107
.EQU	mPORTK,	0x108
.EQU	mPINL,	0x109
.EQU	mDDRL,	0x10A
.EQU	mPORTL,	0x10B

;; Registers:

; only registers 16 and above allow constant setting via LDI


;; 16-bit counting registers, of wich XYZ are 
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
.EQU	P13,	7

.EQU	mPORT13,	mPORTB
.EQU	mDDR13,	mDDRB
.EQU	mPIN13,	mPINB
.EQU	mP13,	0b10000000






.EQU	UDR0,	0xC6
.EQU	UBRR0H,	0xC5
.EQU	UBRR0L,	0xC4
.EQU	UCSR0C,	0xC2
.EQU	UCSR0B,	0xC1
.EQU	UCSR0A,	0xC0

.EQU	UDR1,	0xCE
.EQU	UBRR1H,	0xCD
.EQU	UBRR1L,	0xCC
.EQU	UCSR1C,	0xCA
.EQU	UCSR1B,	0xC9
.EQU	UCSR1A,	0xC8

.EQU	UDRE0,	5		; Transmit Buffer Empty
.EQU	TXC0,	6		; TX Complete
.EQU	RXC0,	7		; RX Complete

.EQU	TXENm,	0x08;
.EQU	RXENm,	0x10;

.EQU	BAUD_9600, 103



.EQU HEAP_RESERVE, 78
.text
.global main
main:

.EQU	MLX1,	0	; Hardware Multiplier
.EQU	MLX2,	1	; Hardware Multiplier
.EQU	TCSl,	2	; Tail Call Special/Save
.EQU	TCSh,	3	; Tail Call Special/Save
.EQU falseReg,	4
.EQU zeroReg,	5
			;	6
			;	7

			;	8
			;	9	
			;	10 	
			;	11	
			;	12	
			;	13	
			;	14	
			;	15	

.EQU	GP1,	16  ; General Purpose 1 		(used by multiplication)
.EQU	GP2,	17  ; General Purpose 2 		(used by multiplication)
.EQU	GP3,	18  ; General Purpose 3 		(used by multiplication)
.EQU	GP4,	19  ; General Purpose 4 		(used by multiplication)
.EQU	GP5,	20  ; General Purpose 5
.EQU	GP6, 	21	; General Purpose 6
			;	22	
.EQU	PCR,	23	; proc call register


.EQU	CCPl,	24
.EQU	CCPh,	25
.EQU	HFPl,	26
.EQU	HFPh,	27
.EQU	CRSl,	28
.EQU	CRSh,	29
.EQU	AFPl,	30
.EQU	AFPh,	31

.EQU	falseHigh,	254
.EQU	trueHigh,	255

LDI GP1, falseHigh
MOV falseReg, GP1
CLR zeroReg

LDI		CRSl,	0
LDI		CRSh,	0
LDI 	HFPl,	lo8(RAM + HEAP_RESERVE)
LDI		HFPh,	hi8(RAM + HEAP_RESERVE)
LDI		CCPl,	0
LDI		CCPh,	0
LDI		AFPl,	lo8(RAMEND)
LDI		AFPh,	hi8(RAMEND)
OUT		SPl,	AFPl				;; Initialise Stack Pointers
OUT		SPh,	AFPh

SBI	DDR13,	P13
CBI	PORT13,	P13

; Set Baud Rate registers
	LDI GP1,	hi8(BAUD_9600)
	STS	UBRR0H,	GP1				;; ..1H for mega 1
	LDI	GP1,	lo8(BAUD_9600)
	STS	UBRR0L,	GP1				;; ..1L for mega 1

; Set control registers
	CLR GP1
	SBR GP1,	TXENm
	SBR GP1,	RXENm
	STS UCSR0B,	GP1				;; ..1B for mega 1

RJMP entry_point

proc_call:
	MOV GP1, CRSh
	ANDI GP1, 224
	LDI GP2, 192
	CPSE GP1, GP2
	RJMP error_notproc
	ANDI CRSh, 31
	MOVW CCPl, CRSl
	LD GP1, Y;CRS
	CPSE GP1, PCR
	RJMP error_numargs
	LDD AFPh, Y+1;CRS
	LDD AFPl, Y+2;CRS
	IJMP

inline_cons:
	ST X+, GP1;HFP
	ST X+, GP2
	ST X+, CRSl
	ST X+, CRSh
	MOVW CRSl, HFPl
	SBIW CRSl, 4
	ORI CRSh, 128
	RET

inline_car:
	MOV GP1, CRSh
	ANDI GP1, 224
	LDI GP2, 128
	CPSE GP1, GP2
	RJMP error_notpair
	ANDI CRSh, 31
	LDD GP1, Y+0; (Y=CCP)
	LDD CRSh, Y+1
	MOV CRSl, GP1
	RET

inline_cdr:
	MOV GP1, CRSh
	ANDI GP1, 224
	LDI GP2, 128
	CPSE GP1, GP2
	RJMP error_notpair
	ANDI CRSh, 31
	LDD GP1, Y+2; (Y=CCP)
	LDD CRSh, Y+3
	MOV CRSl, GP1
	RET

inline_set_car:
	MOV GP3, CRSh
	ANDI GP3, 224
	LDI GP4, 128
	CPSE GP3, GP4
	RJMP error_notpair
	ANDI CRSh, 31
	STD Y+0, GP1
	STD Y+1, GP2
	RET

inline_set_cdr:
	MOV GP3, CRSh
	ANDI GP3, 224
	LDI GP4, 128
	CPSE GP3, GP4
	RJMP error_notpair
	ANDI CRSh, 31
	STD Y+2, GP1
	STD Y+3, GP2
	RET

inline_vector_ref:
	MOV GP3, CRSh
	ANDI GP3, 224
	LDI GP4, 160
	CPSE GP3, GP4
	RJMP error_notvect
	ANDI CRSh, 31
	LD GP3, Y+
	LD GP4, Y+
	CP GP1, GP3
	CPC GP2, GP4
	BRLO inline_vector_ref_ok
	RJMP error_bounds
inline_vector_ref_ok:
	LSL GP1
	ROL GP2
	ADD CRSl, GP1
	ADC CRSh, GP2
	LD GP1, Y
	LDD CRSh, Y+1
	MOV CRSl, GP1
	RET

inline_vector_set:
	MOV GP5, CRSh
	ANDI GP5, 224
	LDI GP6, 160
	CPSE GP5, GP6
	RJMP error_notvect
	ANDI CRSh, 31
	LD GP5, Y+
	LD GP6, Y+
	CP GP1, GP5
	CPC GP2, GP6
	BRLO inline_vector_set_ok
	RJMP error_bounds
inline_vector_set_ok:
	LSL GP1
	ROL GP2
	ADD CRSl, GP1
	ADC CRSh, GP2
	ST Y, GP3
	STD Y+1, GP4
	RET

inline_vector_length:
	MOV GP3, CRSh
	ANDI GP3, 224
	LDI GP4, 160
	CPSE GP3, GP4
	RJMP error_notvect
	ANDI CRSh, 31
	LD GP1, Y
	LDD CRSh, Y+1
	MOV CRSl, GP1
	RET

inline_gt: ; GP1:GP2 > CRSl:CRSh
	CP CRSl, GP1
	CPC CRSh, GP2
	BRLO inline_gt_ok
	LDI CRSh, falseHigh
	CLR CRSl
	RET
inline_gt_ok:
	LDI CRSh, trueHigh
	CLR CRSl
	RET

inline_div: ; GP1:GP2 / CRSl:CRSh
	MOVW GP3, CRSl
	CLR CRSl
	CLR CRSh
	CP GP3, zeroReg
	CPC GP4, zeroReg
	BRNE inline_div_loop
	RJMP error_divzero
inline_div_loop:
	SUB GP1, GP3
	SBC GP2, GP4
	BRLO inline_div_end
	ADIW CRSl, 1
	RJMP inline_div_loop
inline_div_end:
	RET

error_notproc:
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI YL, lo8(1000)
	RCALL util_pause
RJMP error_notproc

error_numargs:
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_numargs

error_notnum:
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_notnum

error_notpair:
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_notpair

error_notvect:
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_notvect

error_bounds:
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_bounds

error_divzero:
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	RCALL util_flash
	LDI YH, hi8(1000)
	LDI HFPl, lo8(1000)
	RCALL util_pause
RJMP error_divzero

error_custom:
	RCALL util_flash
RJMP error_custom


util_serial_send:
PUSH GP1
	util_serial_send_wait1:
		LDS	GP1,	UCSR0A 				;;..1A for mega 1
		SBRS	GP1,	UDRE0
		RJMP	util_serial_send_wait1
		STS	UDR0,	CRSh				;;UDR1 for mega 1
	util_serial_send_wait2:
		LDS	GP1,	UCSR0A
		SBRS	GP1,	UDRE0
		RJMP	util_serial_send_wait2
		STS	UDR0,	CRSl
POP GP1
RET

; INPUT: Y = delay (milliseconds)
util_pause:
	PUSH WH
	PUSH WL

	util_pause_count:       
		LDI WH, hi8(0xFA0)
		LDI WL, lo8(0xFA0)
		util_pause_inner_count:
			SBIW WL, 1
			BRNE util_pause_inner_count
		SBIW YL, 1
		BRNE util_pause_count
	;; NB: In total, this routine takes Y*16002 + 17 operations

	POP WL
	POP WH
RET

; INPUT: Y = delay (microseconds)
util_micropause:
	util_micropause_count:       
		PUSH zeroReg 
		POP zeroReg
		PUSH zeroReg 
		POP zeroReg
		PUSH zeroReg 
		POP zeroReg
		NOP 
		SBIW YL, 1
		BRNE util_micropause_count
RET

util_flash:
	SBI	PORT13,	P13
	LDI YH, hi8(200)
	LDI YL, lo8(200)
	RCALL util_pause
	CBI PORT13, P13
	LDI YH, hi8(200)
	LDI YL, lo8(200)
	RCALL util_pause
RET

entry_point:
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry1))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry1))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after1
proc_entry1: ; =
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	POP GP2
	POP GP1
	CP GP2, CRSh
	BRNE 1f
	LDI CRSh, trueHigh
	CPSE GP1, CRSl
	1:LDI CRSh, falseHigh
	CLR CRSl
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after1:
	STS RAM + 0, CRSh
	STS RAM + 1, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry2))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry2))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after2
proc_entry2: ; >
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_gt
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after2:
	STS RAM + 2, CRSh
	STS RAM + 3, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry3))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry3))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after3
proc_entry3: ; >=
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_gt
	LDI GP1, 1
	EOR CRSh, GP1
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after3:
	STS RAM + 4, CRSh
	STS RAM + 5, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry4))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry4))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after4
proc_entry4: ; <
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_gt
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after4:
	STS RAM + 6, CRSh
	STS RAM + 7, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry5))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry5))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after5
proc_entry5: ; <=
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_gt
	LDI GP1, 1
	EOR CRSh, GP1
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after5:
	STS RAM + 8, CRSh
	STS RAM + 9, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry6))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry6))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after6
proc_entry6: ; not
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	MOVW GP1, CRSl
	CP falseReg, CRSh
	BRNE 1f
	LDI CRSh, trueHigh
	CPSE zeroReg, CRSl
	1:LDI CRSh, falseHigh
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after6:
	STS RAM + 10, CRSh
	STS RAM + 11, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry7))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry7))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after7
proc_entry7: ; ¬
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	LDI GP1, 1
	EOR CRSh, GP1
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after7:
	STS RAM + 12, CRSh
	STS RAM + 13, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry8))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry8))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after8
proc_entry8: ; +
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	ADD CRSl, GP1
	ADC CRSh, GP2
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after8:
	STS RAM + 14, CRSh
	STS RAM + 15, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry9))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry9))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after9
proc_entry9: ; *
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	MOV GP3, CRSh
	MOV GP4, CRSl
	MUL GP1, GP4
	MOV CRSl, MLX1
	MOV CRSh, MLX2
	MUL GP2, GP4
	ADD CRSh, MLX1
	MUL GP1, GP3
	ADD CRSh, MLX1
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after9:
	STS RAM + 16, CRSh
	STS RAM + 17, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry10))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry10))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after10
proc_entry10: ; -
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	SUB CRSl, GP1
	SBC CRSh, GP2
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after10:
	STS RAM + 18, CRSh
	STS RAM + 19, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry11))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry11))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after11
proc_entry11: ; div
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_div
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after11:
	STS RAM + 20, CRSh
	STS RAM + 21, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry12))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry12))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after12
proc_entry12: ; mod
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	CALL inline_div
	ADD GP1, GP3
	ADC GP2, GP4
	MOVW CRSl, GP1
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after12:
	STS RAM + 22, CRSh
	STS RAM + 23, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry13))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry13))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after13
proc_entry13: ; zero?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	MOVW GP1, CRSl
	CP zeroReg, CRSh
	BRNE 1f
	LDI CRSh, trueHigh
	CPSE zeroReg, CRSl
	1:LDI CRSh, falseHigh
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after13:
	STS RAM + 24, CRSh
	STS RAM + 25, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry14))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry14))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after14
proc_entry14: ; number?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ROL CRSh
	ROL CRSh
	ANDI CRSh, 1
	COM CRSh
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after14:
	STS RAM + 26, CRSh
	STS RAM + 27, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry15))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry15))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after15
proc_entry15: ; pair?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 31
	LDI GP1, 159
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 224
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after15:
	STS RAM + 28, CRSh
	STS RAM + 29, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry16))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry16))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after16
proc_entry16: ; vector?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 31
	LDI GP1, 191
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 224
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after16:
	STS RAM + 30, CRSh
	STS RAM + 31, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry17))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry17))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after17
proc_entry17: ; procedure?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 31
	LDI GP1, 223
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 224
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after17:
	STS RAM + 32, CRSh
	STS RAM + 33, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry18))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry18))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after18
proc_entry18: ; char?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 7
	LDI GP1, 231
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 248
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after18:
	STS RAM + 34, CRSh
	STS RAM + 35, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry19))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry19))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after19
proc_entry19: ; boolean?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 7
	LDI GP1, 255
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 248
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after19:
	STS RAM + 36, CRSh
	STS RAM + 37, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry20))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry20))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after20
proc_entry20: ; null?
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	ORI CRSh, 7
	LDI GP1, 239
	CPSE CRSh, GP1
	CBR CRSh, 1
	ORI CRSh, 248
	CLR CRSl
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after20:
	STS RAM + 38, CRSh
	STS RAM + 39, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry21))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry21))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after21
proc_entry21: ; cons
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	POP GP1
	POP GP2
	CALL inline_cons
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after21:
	STS RAM + 40, CRSh
	STS RAM + 41, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry22))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry22))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after22
proc_entry22: ; car
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL inline_car
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after22:
	STS RAM + 42, CRSh
	STS RAM + 43, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry23))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry23))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after23
proc_entry23: ; cdr
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL inline_cdr
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after23:
	STS RAM + 44, CRSh
	STS RAM + 45, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry24))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry24))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after24
proc_entry24: ; set-car!
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	POP GP1
	POP GP2
	CALL inline_set_car
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after24:
	STS RAM + 46, CRSh
	STS RAM + 47, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry25))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry25))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after25
proc_entry25: ; set-cdr!
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	POP GP1
	POP GP2
	CALL inline_set_cdr
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after25:
	STS RAM + 48, CRSh
	STS RAM + 49, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry26))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry26))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after26
proc_entry26: ; vector-length
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL inline_vector_length
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after26:
	STS RAM + 50, CRSh
	STS RAM + 51, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry27))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry27))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after27
proc_entry27: ; vector-ref
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	POP GP1
	POP GP2
	CALL inline_vector_ref
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after27:
	STS RAM + 52, CRSh
	STS RAM + 53, CRSl
	LDI GP1,3
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry28))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry28))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after28
proc_entry28: ; vector-set!
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP3
	POP GP4
	POP GP1
	POP GP2
	CALL inline_vector_set
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after28:
	STS RAM + 54, CRSh
	STS RAM + 55, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry29))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry29))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after29
proc_entry29: ; make-vector!
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	MOVW GP1, CRSl
	MOVW CRSl, HFPl
	ORI CRSh, 160
	ST X+, GP1
	ST X+, GP2
	LSL GP1
	ROL GP2
	ADD HFPl, GP1
	ADC HFPh, GP2
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after29:
	STS RAM + 56, CRSh
	STS RAM + 57, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry30))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry30))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after30
proc_entry30: ; assert
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	SER GP1
	CPSE CRSh, GP1
	JMP error_custom
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after30:
	STS RAM + 58, CRSh
	STS RAM + 59, CRSl
	LDI GP1,0
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry31))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry31))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after31
proc_entry31: ; error
	IN AFPl, SPl
	IN AFPh, SPh
	JMP error_custom
	ADIW AFPl, 0
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after31:
	STS RAM + 60, CRSh
	STS RAM + 61, CRSl
	LDI GP1,0
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry32))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry32))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after32
proc_entry32: ; stacksize
	IN AFPl, SPl
	IN AFPh, SPh
	IN GP1, SPl
	IN GP2, SPh
	LDI CRSl, lo8(RAMEND)
	LDI CRSh, hi8(RAMEND)
	SUB CRSl, GP1
	SBC CRSh, GP2
	ADIW AFPl, 0
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after32:
	STS RAM + 62, CRSh
	STS RAM + 63, CRSl
	LDI GP1,0
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry33))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry33))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after33
proc_entry33: ; heapsize
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW CRSl, HFPl
	SUBI CRSl, lo8(RAM + HEAP_RESERVE)
	SBCI CRSh, hi8(RAM + HEAP_RESERVE)
	ADIW AFPl, 0
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after33:
	STS RAM + 64, CRSh
	STS RAM + 65, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry34))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry34))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after34
proc_entry34: ; pause
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL util_pause
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after34:
	STS RAM + 66, CRSh
	STS RAM + 67, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry35))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry35))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after35
proc_entry35: ; micropause
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL util_micropause
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after35:
	STS RAM + 68, CRSh
	STS RAM + 69, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry36))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry36))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after36
proc_entry36: ; serial-send
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CALL util_serial_send
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after36:
	STS RAM + 70, CRSh
	STS RAM + 71, CRSl
	LDI GP1,2
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry37))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry37))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after37
proc_entry37: ; digital-state
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	POP GP3
	LD GP4, Y
	LDI CRSh, trueHigh
	AND GP4, GP3
	CPSE GP4, GP3
	LDI CRSh, falseHigh
	CLR CRSl
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after37:
	STS RAM + 72, CRSh
	STS RAM + 73, CRSl
	LDI GP1,3
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry38))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry38))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after38
proc_entry38: ; set-digital-state
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP4
	POP GP3
	LD GP5, Y
	OR GP5, GP3
	COM GP3
	SBRS GP4, 0
	AND GP5, GP3
	ST Y, GP5
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after38:
	STS RAM + 74, CRSh
	STS RAM + 75, CRSl
	LDI GP1,1
	ST X+, GP1;HFP
	LDI GP1, hi8(pm(proc_entry39))
	ST X+, GP1
	LDI GP1, lo8(pm(proc_entry39))
	ST X+, GP1
	ST X+, CCPl
	ST X+, CCPh
	MOVW CRSl, HFPl
	SBIW CRSl, 5
	ORI CRSh, 192
	JMP proc_after39
proc_entry39: ; char->number
	IN AFPl, SPl
	IN AFPh, SPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CLR CRSh
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	IJMP
proc_after39:
	STS RAM + 76, CRSh
	STS RAM + 77, CRSl
SBI PORT13, P13
