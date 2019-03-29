* ***************************************
*	Name: Bryan Powell
*	Date: 25 Apr 2017
*	Micro Processors
*	Lab #9: Input Capture
*	
*	This program captures two wave crests
*	and measures the period of the wave.
*	If the frequency is less than 100 Hz
*	or greater than 10 kHz, an error message
*	is displayed.
* ****************************************

REGBAS	equ	$1000
TFLG1	equ	$23
TCTL1	equ	$20
TCTL2	equ	$21
TMSK1	equ	$22
TCNT	equ	$0E
TIC1	equ	$10
CLEAR	equ	$04
OUTSTRG	equ	$FFC7	;outstrg buffalo subroutine
OUTA	equ	$FFB8	;outa buffalo subroutine


* Variables
	org	$100
pr_edge rmb	2
nx_edge	rmb	2
period	rmb	2
temp1	rmb	2
freqh	rmb	2
dbufr	rmb	8
frq_flg	rmb	1


* Messages
msglo	fcc	"The frequency measured is too low, below 100 Hz threshold"
	fcb	$04
msghi	fcc	"The frequency measured is too high, above 10 kHz threshold"
	fcb	$04
msgfreq	fcb	"The measured frequency in Hz is:"
	fcb	$04

* ***********************************************
* 	Vector Table *
* ***********************************************
*	org	$FFE8
*	fdb	IC1_ISR

	org	$E8
	jmp	IC1_ISR



* **********************************************
*	Main	    *
* **********************************************	
	org	$b600
	lds	#$01FF
	jsr	IC1_init;initializes IC1 to desired settings
	ldy	#00	;initializes previous edge to 0
	sty	pr_edge
	
repeat	cli		;enables global interrupts

	ldab	#06	;creates a delay of one second to gather wave data
wait	jsr	Delay
	decb
	bne	wait
	
	sei		;stops interrupts
	jsr	P2FC	;subroutine to change period to frequency
	ldaa	frq_flg	;checks to make sure frequency was within limits
	beq	repeat
	ldx	#msgfreq;prints frequency message and frequency
	jsr	outstrg
	jsr	Display

	clr	frq_flg
*	ldaa	#00	;clears frequency flag for next iteration
*	staa	frq_flg
	bra	repeat

	swi




* ***********************************************
*	Subroutines *
* ***********************************************

* ***********************************************
*IC1_init -- subroutine to configure IC1 and initialize
IC1_init ldx	#REGBAS 
	ldaa	#CLEAR	;clears IC1 Flag
	staa	TFLG1,X
	ldaa	#$10	;configures TCTL2 to capture rising edge of IC1
	staa	TCTL2,X
	bset	TMSK1,X	CLEAR	;enables IC1 interrupt
	rts

* ***********************************************
* IC1_ISR -- interrupt service routine to capture timestamps
* on rising edges of incoming waves
IC1_ISR	ldx	#REGBAS
	ldd	TIC1,X
	std	nx_edge
	ldy	pr_edge
	beq	quit
	subd	pr_edge
	std	period	
quit	bset	TFLG1,X	CLEAR
	ldd	nx_edge
	std	pr_edge
	rti

* ***********************************************
* Delay	---	writes a 1/6 sec delay into run time
Delay	pshx
	ldx	#33333
loop_d	nop
	nop
	dex
	bne	loop_d
	pulx
	rts

* ***********************************************
* Period - to - Freq converter
* converts the period observed to frequency
P2FC	ldx	period
	cpx	#$4E20		;Hex equivalent period of 20,000 eclock cycles
	bhs	too_lo		;any value higher means frequency is too low
	cpx	#$C8		;Hex equivalent period of 200 eclock cycles
	bls	too_hi		;any value smaller means frequency is too high
	ldd	#32		;CHANGE THIS VALUE (Maybe)
	fdiv
	stx	temp1
	ldd	temp1
	lsrd
	lsrd
	lsrd
	clr	freqh
	staa	freqh+1
	lsrd
	lsrd
	std	temp1
	xgdx
	subd	temp1
	xgdx
	lsrd
	std	temp1
	adda	freqh+1
	staa	freqh+1
	xgdx
	subd	temp1
	addd	freqh
	std	freqh
	ldaa	#01
	staa	Frq_flg
	bsr	H2D
	rts

too_lo	ldx	#msglo
	jsr	outstrg
	ldaa	#0
	staa	Frq_flg
	rts
too_hi	ldx	#msghi
	jsr	outstrg
	ldaa	#0
	staa	Frq_flg
	rts

* ************************************************
* Hex -to - Decimal converter 
* converts hex frequency to a decimal value and stores in dbufr
H2D	ldd	freqh
	ldx	#10000
	idiv
	xgdx
	addb	#$30
	stab	dbufr
	xgdx
	ldx	#1000
	idiv
	xgdx
	addb	#$30
	stab	dbufr+1
	xgdx
	ldx	#100
	idiv
	xgdx
	addb	#$30
	stab	dbufr+2
	xgdx
	ldx	#10
	idiv
	addb	#$30
	stab	dbufr+4
	xgdx
	addb	#$30
	stab	dbufr+3
	rts
* **************************************************
* Display -- displays the 5 digit frequency (stored at dbufr)
Display	ldx	#dbufr
	ldaa	#$30
	cmpa	0,X
	bne	P10K
	bsr	skp1
	cmpa	0,X
	bne	P1K
	bsr	skp1
	bsr	skp1
	dex
	cmpa	0,X
	bne	P100
	bsr	skp1
	cmpa	0,X
	bne	P10
	bsr	skp1
	bra	P1
P10K	ldaa	0,X
	jsr	outa
	inx
P1K	ldaa	0,X
	jsr	outa
	inx
P100	ldaa	0,X
	jsr	outa
	inx
P10	ldaa	0,X
	jsr	outa
	inx
P1	ldaa	0,X
	jsr	outa
	rts
* ******************************************************
* skp1	-- increments x and prints a space (consider changing)
skp1	psha
	inx
	ldaa	#$20
	jsr	outa
	pula
	rts		




