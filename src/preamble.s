/* ======================= Microscheme =======================
 * Runtime startup code for AVR
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

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
LDI		AFPl,	lo8(_ms_stack)
LDI		AFPh,	hi8(_ms_stack)

OUT SPl, AFPl
OUT SPh, AFPh

SBI	DDR13,	P13
CBI	PORT13,	P13

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
