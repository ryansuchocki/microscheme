.EQU	PORT13,	0x05	
.EQU	DDR13,	0x04	
.EQU	P13,	7		
.EQU	UDR0,	0xC6	
.EQU	UBRR0H,	0xC5	
.EQU	UBRR0L,	0xC4	
.EQU	UCSR0C,	0xC2	
.EQU	UCSR0B,	0xC1	
.EQU	UCSR0A,	0xC0	
.EQU	TXEN0,	3		
.EQU	RXEN0,	4		
.EQU	UDRE0,	5		
.EQU	TXC0,	6		
.EQU	RXC0,	7		
.EQU	BAUD_9600, 103	
	.global _global_0
	.data
	.size _global_0, 2
_global_0:
	.word falseHigh
	.text
	.global _global_1
	.data
	.size _global_1, 2
_global_1:
	.word falseHigh
	.text
	.global _global_2
	.data
	.size _global_2, 2
_global_2:
	.word falseHigh
	.text
	.global _global_3
	.data
	.size _global_3, 2
_global_3:
	.word falseHigh
	.text
	.global _global_4
	.data
	.size _global_4, 2
_global_4:
	.word falseHigh
	.text
	.global _global_5
	.data
	.size _global_5, 2
_global_5:
	.word falseHigh
	.text
	.global _global_6
	.data
	.size _global_6, 2
_global_6:
	.word falseHigh
	.text
	.global _global_7
	.data
	.size _global_7, 2
_global_7:
	.word falseHigh
	.text
	.global _global_8
	.data
	.size _global_8, 2
_global_8:
	.word falseHigh
	.text
	.global _global_9
	.data
	.size _global_9, 2
_global_9:
	.word falseHigh
	.text
	.global _global_10
	.data
	.size _global_10, 2
_global_10:
	.word falseHigh
	.text
	.global _global_11
	.data
	.size _global_11, 2
_global_11:
	.word falseHigh
	.text
	.global _global_12
	.data
	.size _global_12, 2
_global_12:
	.word falseHigh
	.text
	.global _global_13
	.data
	.size _global_13, 2
_global_13:
	.word falseHigh
	.text
	.global _global_14
	.data
	.size _global_14, 2
_global_14:
	.word falseHigh
	.text
	.global _global_15
	.data
	.size _global_15, 2
_global_15:
	.word falseHigh
	.text
	.global _global_16
	.data
	.size _global_16, 2
_global_16:
	.word falseHigh
	.text
	.global _global_17
	.data
	.size _global_17, 2
_global_17:
	.word falseHigh
	.text
	.global _global_18
	.data
	.size _global_18, 2
_global_18:
	.word falseHigh
	.text
.text
.global main
main:

.EQU	MLX1,	0	; Hardware Multiplier
.EQU	MLX2,	1	; Hardware Multiplier
.EQU	TCSl,	2	; Tail Call Special/Save
.EQU	TCSh,	3	; Tail Call Special/Save
.EQU falseReg,	4
.EQU zeroReg,	5
.EQU c_sreg, 	6
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

.EQU	SREG,	0x3F

.EQU	falseHigh,	254
.EQU	trueHigh,	255

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

.EQU	SPl,	0x3D
.EQU	SPh,	0x3E

LDI GP1, falseHigh
MOV falseReg, GP1
CLR zeroReg

CLI
IN c_sreg, SREG

LDI		CRSl,	0
LDI		CRSh,	0
LDI 	HFPl,	lo8(_end)
LDI		HFPh,	hi8(_end)
LDI		CCPl,	0
LDI		CCPh,	0
LDI		AFPl,	lo8(__stack)
LDI		AFPh,	hi8(__stack)

SBI	DDR13,	P13
CBI	PORT13,	P13

# ; Set Baud Rate registers
# 	LDI GP1,	hi8(BAUD_9600)
# 	STS	UBRR0H,	GP1				;; ..1H for mega 1
# 	LDI	GP1,	lo8(BAUD_9600)
# 	STS	UBRR0L,	GP1				;; ..1L for mega 1

# ; Set control registers
# 	CLR GP1
# 	SBR GP1,	TXENm
# 	SBR GP1,	RXENm
# 	STS UCSR0B,	GP1				;; ..1B for mega 1

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

before_c_func:
	POP r2
	POP r3
		PUSH CCPl
		PUSH CCPh
		PUSH HFPl
		PUSH HFPh
		PUSH AFPl
		PUSH AFPh
		PUSH r1
		CLR r1
	PUSH r3
	PUSH r2
	OUT SREG, c_sreg
	RET

after_c_func:
	IN c_sreg, SREG
	CLI
	POP r2
	POP r3
		MOVW CRSl, r24
		POP r1
		POP AFPh
		POP AFPl
		POP HFPh
		POP HFPl
		POP CCPh
		POP CCPl
	PUSH r3
	PUSH r2
	RET

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
	LDD GP1, Y+0; (Y=CRS)
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
	LDD GP1, Y+2; (Y=CRS)
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
	LDI GP1, lo8(54)
	LDI GP2, hi8(54)
	ST X+, GP1
	ST X+, GP2
	LDI CRSh, 0
	LDI CRSl, 44
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 44
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 44
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 44
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 50
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 44
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 0
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 38
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 50
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 50
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 50
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 1
	LDI CRSl, 9
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 35
	ST X+, CRSl
	ST X+, CRSh
	MOVW CRSl, HFPl
	SUBI CRSl, lo8(110)
	SBCI CRSh, hi8(110)
	ORI CRSh, 160
	STS _global_0+1, CRSh
	STS _global_0, CRSl
	LDI GP1, lo8(70)
	LDI GP2, hi8(70)
	ST X+, GP1
	ST X+, GP2
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 16
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 32
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 64
	ST X+, CRSl
	ST X+, CRSh
	LDI CRSh, 0
	LDI CRSl, 128
	ST X+, CRSl
	ST X+, CRSh
	MOVW CRSl, HFPl
	SUBI CRSl, lo8(142)
	SBCI CRSh, hi8(142)
	ORI CRSh, 160
	STS _global_1+1, CRSh
	STS _global_1, CRSl
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
proc_entry1: ; set-ddr
	MOVW AFPl, GP5
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDS CRSh, _global_1+1
	LDS CRSl, _global_1
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDS CRSh, _global_0+1
	LDS CRSl, _global_0
	POP GP1
	POP GP2
	CALL inline_vector_ref
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	ADD CRSl, GP1
	ADC CRSh, GP2
	POP GP4
	POP GP3
	LD GP5, Y
	OR GP5, GP3
	COM GP3
	SBRS GP4, 0
	AND GP5, GP3
	ST Y, GP5
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP AFPl
	POP AFPh
	IJMP
proc_after1:
	STS _global_2+1, CRSh
	STS _global_2, CRSl
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
proc_entry2: ; set-pin
	MOVW AFPl, GP5
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDS CRSh, _global_1+1
	LDS CRSl, _global_1
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSh
	PUSH CRSl
	LDS CRSh, _global_0+1
	LDS CRSl, _global_0
	POP GP1
	POP GP2
	CALL inline_vector_ref
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	ADD CRSl, GP1
	ADC CRSh, GP2
	POP GP4
	POP GP3
	LD GP5, Y
	OR GP5, GP3
	COM GP3
	SBRS GP4, 0
	AND GP5, GP3
	ST Y, GP5
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	ADIW AFPl, 4
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP AFPl
	POP AFPh
	IJMP
proc_after2:
	STS _global_3+1, CRSh
	STS _global_3, CRSl
	LDI GP1,1
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
proc_entry3: ; output
	MOVW AFPl, GP5
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 255
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_2+1
	LDS CRSl, _global_2
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 4
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 4
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 2
	JMP proc_call
proc_after3:
	STS _global_4+1, CRSh
	STS _global_4, CRSl
	LDI GP1,1
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
proc_entry4: ; high
	MOVW AFPl, GP5
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 255
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_3+1
	LDS CRSl, _global_3
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 4
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 4
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 2
	JMP proc_call
proc_after4:
	STS _global_5+1, CRSh
	STS _global_5, CRSl
	LDI GP1,1
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
proc_entry5: ; low
	MOVW AFPl, GP5
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 254
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_3+1
	LDS CRSl, _global_3
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 2
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 4
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 4
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 2
	JMP proc_call
proc_after5:
	STS _global_6+1, CRSh
	STS _global_6, CRSl
	LDI GP1,4
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
proc_entry6: ; shift-out-bits
	MOVW AFPl, GP5
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret1))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret1))
	PUSH GP1
	LDD CRSh, Z+7
	LDD CRSl, Z+8
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	ROL CRSh
	ROL CRSh
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_3+1
	LDS CRSl, _global_3
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 2
	JMP proc_call
proc_ret1:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret2))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret2))
	PUSH GP1
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret3))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret3))
	PUSH GP1
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_5+1
	LDS CRSl, _global_5
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret3:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_6+1
	LDS CRSl, _global_6
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret2:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	MOVW GP1, CRSl
	CP zeroReg, CRSh
	BRNE 1f
	LDI CRSh, trueHigh
	CPSE zeroReg, CRSl
	1:LDI CRSh, falseHigh
	CLR CRSl
	CPSE CRSh, falseReg
	JMP if_conseq1
	LDD CRSh, Z+7
	LDD CRSl, Z+8
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	LSL CRSl
	ROL CRSh
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
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
	SUB CRSl, GP1
	SBC CRSh, GP2
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_7+1
	LDS CRSl, _global_7
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 8
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 8
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 8
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 4
	JMP proc_call
	JMP if_end1
if_conseq1:
	LDI CRSh, 255
	LDI CRSl, 0
if_end1:
	ADIW AFPl, 8
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP AFPl
	POP AFPh
	IJMP
proc_after6:
	STS _global_7+1, CRSh
	STS _global_7, CRSl
	LDI GP1,3
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
proc_entry7: ; noops
	MOVW AFPl, GP5
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	MOVW GP1, CRSl
	CP zeroReg, CRSh
	BRNE 1f
	LDI CRSh, trueHigh
	CPSE zeroReg, CRSl
	1:LDI CRSh, falseHigh
	CLR CRSl
	CPSE CRSh, falseReg
	JMP if_conseq2
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret4))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret4))
	PUSH GP1
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 15
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_7+1
	LDS CRSl, _global_7
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret4:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
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
	SUB CRSl, GP1
	SBC CRSh, GP2
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_8+1
	LDS CRSl, _global_8
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
	JMP if_end2
if_conseq2:
	LDI CRSh, 255
	LDI CRSl, 0
if_end2:
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP AFPl
	POP AFPh
	IJMP
proc_after7:
	STS _global_8+1, CRSh
	STS _global_8, CRSl
	LDI GP1,3
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
proc_entry8: ; shift-out
	MOVW AFPl, GP5
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 3
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	POP GP1
	POP GP2
	CALL inline_vector_ref
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	PUSH CRSh
	MOVW GP3, HFPl
	IN HFPl, SPl
	IN HFPh, SPh
	SBIW HFPl, 5
	OUT SPl, HFPl
	OUT SPh, HFPh
	ADIW HFPl, 1
	LDI GP1,7
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
	MOVW HFPl, GP3
	JMP proc_after9
proc_entry9: ; Anonymous
	MOVW AFPl, GP5
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret5))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret5))
	PUSH GP1
	LDD CRSh, Z+9
	LDD CRSl, Z+10
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_6+1
	LDS CRSl, _global_6
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret5:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret6))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret6))
	PUSH GP1
	LDD CRSh, Z+13
	LDD CRSl, Z+14
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+11
	LDD CRSl, Z+12
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDD CRSh, Z+7
	LDD CRSl, Z+8
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	SUB CRSl, GP1
	SBC CRSh, GP2
	SBRC CRSh, 7
	JMP error_notnum
	POP GP1
	POP GP2
	SUB CRSl, GP1
	SBC CRSh, GP2
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_8+1
	LDS CRSl, _global_8
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret6:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret7))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret7))
	PUSH GP1
	LDD CRSh, Z+13
	LDD CRSl, Z+14
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+11
	LDD CRSl, Z+12
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 15
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_7+1
	LDS CRSl, _global_7
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret7:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret8))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret8))
	PUSH GP1
	LDD CRSh, Z+13
	LDD CRSl, Z+14
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+11
	LDD CRSl, Z+12
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_8+1
	LDS CRSl, _global_8
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret8:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDD CRSh, Z+9
	LDD CRSl, Z+10
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_5+1
	LDS CRSl, _global_5
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 14
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 2
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 2
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 1
	JMP proc_call
proc_after9:
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 14
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 5
	ADIW AFPl, 14
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 7
	IN CRSh, SPh
	IN CRSl, SPl
	ADIW CRSl, 1
	ORI CRSh, 192
	JMP proc_call
proc_after8:
	STS _global_9+1, CRSh
	STS _global_9, CRSl
	LDI GP1,4
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
proc_entry10: ; def-max7
	MOVW AFPl, GP5
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	PUSH CRSh
	PUSH CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret9))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret9))
	PUSH GP1
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret10))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret10))
	PUSH GP1
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_4+1
	LDS CRSl, _global_4
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret10:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_6+1
	LDS CRSl, _global_6
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret9:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSh
	PUSH CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret11))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret11))
	PUSH GP1
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret12))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret12))
	PUSH GP1
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_4+1
	LDS CRSl, _global_4
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret12:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_6+1
	LDS CRSl, _global_6
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret11:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSh
	PUSH CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret13))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret13))
	PUSH GP1
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret14))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret14))
	PUSH GP1
	LDD CRSh, Z+7
	LDD CRSl, Z+8
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_4+1
	LDS CRSl, _global_4
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret14:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_6+1
	LDS CRSl, _global_6
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 1
	JMP proc_call
proc_ret13:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH CRSh
	PUSH CRSl
	LDI GP1, lo8(4)
	LDI GP2, hi8(4)
	ST X+, GP1
	ST X+, GP2
	POP CRSl
	POP CRSh
	ST X+, CRSl
	ST X+, CRSh
	POP CRSl
	POP CRSh
	ST X+, CRSl
	ST X+, CRSh
	POP CRSl
	POP CRSh
	ST X+, CRSl
	ST X+, CRSh
	POP CRSl
	POP CRSh
	ST X+, CRSl
	ST X+, CRSh
	MOVW CRSl, HFPl
	SUBI CRSl, lo8(10)
	SBCI CRSh, hi8(10)
	ORI CRSh, 160
	ADIW AFPl, 8
	OUT SPl, AFPl
	OUT SPh, AFPh
	POP AFPl
	POP AFPh
	IJMP
proc_after10:
	STS _global_10+1, CRSh
	STS _global_10, CRSl
	LDI GP1,4
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
proc_entry11: ; digit
	MOVW AFPl, GP5
	LDD CRSh, Z+7
	LDD CRSl, Z+8
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	SBRC CRSh, 7
	JMP error_notnum
	PUSH CRSh
	PUSH CRSl
	LDI CRSh, 1
	LDI CRSl, 0
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
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 8
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after11:
	STS _global_11+1, CRSh
	STS _global_11, CRSl
	LDI GP1,3
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
proc_entry12: ; decode
	MOVW AFPl, GP5
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 9
	LDI CRSl, 0
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
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after12:
	STS _global_12+1, CRSh
	STS _global_12, CRSl
	LDI GP1,3
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
proc_entry13: ; intensity
	MOVW AFPl, GP5
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 10
	LDI CRSl, 0
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
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after13:
	STS _global_13+1, CRSh
	STS _global_13, CRSl
	LDI GP1,3
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
proc_entry14: ; scan-limit
	MOVW AFPl, GP5
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 11
	LDI CRSl, 0
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
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after14:
	STS _global_14+1, CRSh
	STS _global_14, CRSl
	LDI GP1,3
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
proc_entry15: ; show
	MOVW AFPl, GP5
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CPSE CRSh, falseReg
	JMP if_conseq3
	LDI CRSh, 12
	LDI CRSl, 0
	JMP if_end3
if_conseq3:
	LDI CRSh, 12
	LDI CRSl, 1
if_end3:
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after15:
	STS _global_15+1, CRSh
	STS _global_15, CRSl
	LDI GP1,3
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
proc_entry16: ; test
	MOVW AFPl, GP5
	LDD CRSh, Z+5
	LDD CRSl, Z+6
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+3
	LDD CRSl, Z+4
	PUSH CRSl
	PUSH CRSh
	LDD CRSh, Z+1
	LDD CRSl, Z+2
	CPSE CRSh, falseReg
	JMP if_conseq4
	LDI CRSh, 15
	LDI CRSl, 0
	JMP if_end4
if_conseq4:
	LDI CRSh, 15
	LDI CRSl, 1
if_end4:
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_9+1
	LDS CRSl, _global_9
	IN GP3, SPl
	IN GP4, SPh
	ADIW AFPl, 6
	OUT SPl, AFPl
	OUT SPh, AFPh
	SBIW AFPl, 6
	MOVW GP5, AFPl
	MOVW AFPl, GP3
	ADIW AFPl, 6
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 3
	JMP proc_call
proc_after16:
	STS _global_16+1, CRSh
	STS _global_16, CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret15))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret15))
	PUSH GP1
	LDI CRSh, 0
	LDI CRSl, 2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 3
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_10+1
	LDS CRSl, _global_10
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret15:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	STS _global_17+1, CRSh
	STS _global_17, CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret16))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret16))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_12+1
	LDS CRSl, _global_12
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret16:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret17))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret17))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 15
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_13+1
	LDS CRSl, _global_13
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret17:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret18))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret18))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 7
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_14+1
	LDS CRSl, _global_14
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret18:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret19))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret19))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 254
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_16+1
	LDS CRSl, _global_16
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret19:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret20))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret20))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 255
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_15+1
	LDS CRSl, _global_15
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret20:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret21))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret21))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret21:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret22))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret22))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 2
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret22:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret23))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret23))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 3
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret23:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret24))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret24))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 4
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret24:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret25))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret25))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 5
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret25:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret26))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret26))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 6
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret26:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret27))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret27))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 7
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret27:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret28))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret28))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 8
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 1
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_11+1
	LDS CRSl, _global_11
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 4
	JMP proc_call
proc_ret28:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDI GP1,0
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
proc_entry17: ; loop
	MOVW AFPl, GP5
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret29))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret29))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 255
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_16+1
	LDS CRSl, _global_16
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret29:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDI CRSh, 1
	LDI CRSl, 244
	CALL util_pause
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret30))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret30))
	PUSH GP1
	LDS CRSh, _global_17+1
	LDS CRSl, _global_17
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 0
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDI CRSh, 254
	LDI CRSl, 0
	PUSH CRSl
	PUSH CRSh
	LDS CRSh, _global_16+1
	LDS CRSl, _global_16
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 3
	JMP proc_call
proc_ret30:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
	LDI CRSh, 1
	LDI CRSl, 244
	CALL util_pause
	LDS CRSh, _global_18+1
	LDS CRSl, _global_18
	IN GP3, SPl
	IN GP4, SPh
	OUT SPl, AFPl
	OUT SPh, AFPh
	MOVW GP5, AFPl
	MOVW AFPl, GP3
1:	CP AFPl, GP3
	CPC AFPh, GP4
	BREQ 2f
	LD GP1, Z
	SBIW AFPl, 1
	PUSH GP1
	RJMP 1b
2:	LDI PCR, 0
	JMP proc_call
proc_after17:
	STS _global_18+1, CRSh
	STS _global_18, CRSl
	PUSH AFPh
	PUSH AFPl
	PUSH CCPh
	PUSH CCPl
	LDI GP1, hi8(pm(proc_ret31))
	PUSH GP1
	LDI GP1, lo8(pm(proc_ret31))
	PUSH GP1
	LDS CRSh, _global_18+1
	LDS CRSl, _global_18
	IN AFPl, SPl
	IN AFPh, SPh
	MOVW GP5, AFPl
	LDI PCR, 0
	JMP proc_call
proc_ret31:
	POP CCPl
	POP CCPh
	POP AFPl
	POP AFPh
SBI PORT13, P13
JMP _exit
