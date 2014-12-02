	.file	"ffitest.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
.global	myfunc
	.type	myfunc, @function
myfunc:
	push r28
	push r29
	rcall .
	rcall .
	rcall .
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 6 */
/* stack size = 8 */
.L__stack_usage = 8
	std Y+2,r25
	std Y+1,r24
	std Y+4,r23
	std Y+3,r22
	std Y+6,r21
	std Y+5,r20
	ldd r18,Y+1
	ldd r19,Y+2
	ldd r24,Y+3
	ldd r25,Y+4
	add r24,r18
	adc r25,r19
	cpi r24,2
	cpc r25,__zero_reg__
	brsh .L2
	ldi r24,0
	ldi r25,0
	rjmp .L1
.L2:
	ldd r18,Y+1
	ldd r19,Y+2
	ldd r24,Y+3
	ldd r25,Y+4
	add r24,r18
	adc r25,r19
	cpi r24,4
	cpc r25,__zero_reg__
	brsh .L4
	ldi r24,lo8(1)
	ldi r25,0
	rjmp .L1
.L4:
	ldd r18,Y+1
	ldd r19,Y+2
	ldd r24,Y+3
	ldd r25,Y+4
	add r24,r18
	adc r25,r19
	cpi r24,6
	cpc r25,__zero_reg__
	brsh .L5
	ldd r24,Y+5
	ldd r25,Y+6
	rjmp .L1
.L5:
.L1:
/* epilogue start */
	adiw r28,6
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	ret
	.size	myfunc, .-myfunc
	.ident	"GCC: (GNU) 4.9.1"
