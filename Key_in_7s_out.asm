* Bryan Powell & Trebor
* Date written: 31 Mar 2017	Date demo'd: 5 Apr 2017
* This program scans a 16-key keypad for input and 
* displays it to a seven-segment display


REGBAS	equ	$1000
PORTC	equ	$03
PORTB	equ	$04
DDRC	equ	$07

	org	$0100
f_test	fcb	$81,$cf,$92		;0,1,2
	fcb	$86,$cc,$a4		;3,4,5
	fcb	$a0,$8f,$80,$8c		;6,7,8,9

lu_tab	fcb	$cf,$92,$86,$88
	fcb	$cc,$a4,$a0,$e0
	fcb	$8f,$80,$8c,$f2
	fcb	$fe,$81,$98,$c2

pulse	fcb	$70,$b0,$d0,$e0
mod	rmb	1			;modifier to hold value of distance from a point, should not exceed 15

* *******MAIN***************************************
	org	$b600
	lds	#$01ff
	ldy	#REGBAS
	ldaa	#$f0
	staa	DDRC,Y
	clrb
	jsr	Intro
	ldaa	#$ff
	staa	PORTB,Y
	jsr	SCAN_KEY
	swi

* ***************************************************
* Delay	---	writes a 1/6 sec delay into run time
Delay	pshx
	ldx	#33333
loop_d	nop
	nop
	dex
	bne	loop_d
	pulx
	rts

* ****************************************************************
* Disp-data -	Displays data to the 7-seg display (with a delay)
Disp_data staa	PORTB,Y
	bsr	Delay
	bsr	Delay
	rts


* **********************************************
* Intro	---	displays numbers 0 thru 9 twice
Intro	ldx	#f_test
loop_i	ldaa	0,X
	bsr	Disp_data
	inx
	cpx	#$010A
	bne	loop_i
	incb
	cmpb	#02
	bne	Intro
	rts

* *********************************************************************
* Scan_key -	scans thru each column of the keypad, checks for input
Scan_key ldx	#pulse


	
	ldab	0,X			;1st column
	stab	PORTC,Y
	brclr	PORTC,Y %00001000 key1
	brclr	PORTC,Y %00000100 key4
	brclr	PORTC,Y %00000010 key7
	brclr	PORTC,Y %00000001 keySt
	bra	col2 ;skips to next column since no input

key1	ldaa	#00
	staa	mod
	jsr	Which_key
	bra	Scan_key
key4	ldaa	#04
	staa	mod
	jsr	Which_key
	bra	Scan_key
key7	ldaa	#08
	staa	mod
	jsr	Which_key
	bra	Scan_key
keySt	ldaa	#12
	staa	mod
	jsr	Which_key
	bra	Scan_key


col2	inx
	ldab	0,X			;2nd column
	stab	PORTC,Y
	brclr	PORTC,Y %00001000 key2
	brclr	PORTC,Y %00000100 key5
	brclr	PORTC,Y %00000010 key8
	brclr	PORTC,Y %00000001 key0
	bra	col3 ;skips to next column since no input

key2	ldaa	#01
	staa	mod
	jsr	Which_key
	bra	Scan_key
key5	ldaa	#05
	staa	mod
	jsr	Which_key
	jsr	Scan_key
key8	ldaa	#09
	staa	mod
	jsr	Which_key
	jmp	Scan_key
key0	ldaa	#13
	staa	mod
	jsr	Which_key
	jmp	Scan_key

col3	inx
	ldab	0,X			;3rd column
	stab	PORTC,Y
	brclr	PORTC,Y %00001000 key3
	brclr	PORTC,Y %00000100 key6
	brclr	PORTC,Y %00000010 key9
	brclr	PORTC,Y %00000001 keyP
	bra	col4 ;skips to next column since no input

key3	ldaa	#02
	staa	mod
	jsr	Which_key
	jmp	Scan_key
key6	ldaa	#06
	staa	mod
	jsr	Which_key
	jmp	Scan_key
key9	ldaa	#10
	staa	mod
	jsr	Which_key
	jmp	Scan_key
keyP	ldaa	#14
	staa	mod
	jsr	Which_key
	jmp	Scan_key


col4	inx
	ldab	0,X			;4th column
	stab	PORTC,Y
	brclr	PORTC,Y %00001000 keyA
	brclr	PORTC,Y %00000100 keyB
	brclr	PORTC,Y %00000010 keyC
	brclr	PORTC,Y %00000001 keyD
	jmp	Scan_key

keyA	ldaa	#03
	staa	mod
	jsr	Which_key
	jmp	Scan_key
keyB	ldaa	#07
	staa	mod
	jsr	Which_key
	jmp	Scan_key
keyC	ldaa	#11
	staa	mod
	jsr	Which_key
	jmp	Scan_key
keyD	ldaa	#15
	staa	mod
	jsr	Which_key
	jmp	Scan_key 

	rts


* ********************************************************
*Which_key -	sends the key that was input to Disp_data
Which_key pshx
	ldx	#lu_tab
	ldab	mod
	abx
	ldaa 	0,X
	jsr	Disp_data
	pulx
	rts
