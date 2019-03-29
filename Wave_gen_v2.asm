* Bryan Powell & Trebor
* Date written: 18 Apr 2017	Date demo'd: 19 Apr 2017
* This program generates a square wave of varying frequencies out of OC2
* The freq. is determined by input from port C


* Constant declarations:
REGBAS	equ	$1000
TMSK1	equ	$22
TCNT	equ	$0E
PORTA	equ	$00
PORTC	equ	$03
DDRC	equ	$07
OC1D	equ	$0D
OC1M	equ	$0C
TOC1	equ	$16
TOC2	equ	$18
TCTL1	equ	$20
TFLG1	equ	$23
tctl1_in equ	$80
oc1m_in	equ	$40
oc1d_in	equ	$40
PACTL	equ	$26
OC1	equ	$80
OC2	equ	$40
CLEAR	equ	$40

	org	$0000
Table	fdb	2000,2000,1000,1000,1000,500,500,500
	fdb	200,600,400,500,600,350,400,450





* Main **********************************************
	org $b600
	ldy	#REGBAS
	bset	PACTL,Y	$80	;configure PA7 for output
	ldaa	#oc1m_in	;OC1 control OC2
	staa	OC1M,Y
	ldaa	#tctl1_in	;define OC2 action to pull OC2 low
	staa	TCTL1,Y
	ldaa	#oc1d_in	;define OC1 action to pull OC2 high
	staa	OC1D,Y		
	bclr	TFLG1,Y	$3F	;clear OC1 & OC2 flags
	bclr	PORTA,Y	$40	;pull OC2 pin low
	ldaa	#00		;set DDRC for input
	staa	DDRC,Y
	
	ldx	#Table
	ldd	TCNT,Y
	addd	0,X
	std	TOC1,Y
	addd	16,X
	std	TOC2,Y
	bclr	TFLG1,Y $3F	;clears both OC1 and OC2 flags	

	
loop	ldx	#Table
	ldab	PORTC,Y
	andb	#$07
	lslb
	abx

;	ldd	TOC1,Y
;	addd	0,X
;	std	TOC1,Y
;	addd	16,X
;	std	TOC2,Y
;	bclr	TFLG1,Y $3F	;clears both OC1 and OC2 flags
	

high	brclr	TFLG1,Y OC1 high ;wait until OC2F flag set to 1
	bclr	TFLG1,Y $7F	;clear OC1 Flag
	ldd	TOC1,Y		;toggle OC2 pin after selected cycles
	addd	0,X		
	std	TOC1,Y
	
low	brclr	TFLG1,Y OC2 low	;wait until OC2F set to 1
	bclr	TFLG1,Y $BF	;clear OC2F flag
	ldd	TOC1,Y		;start next OC2 compare operation
	addd	16,X		;will toggle OC2 pin
	std	TOC2,Y
	bra	loop
	
	swi