* Bryan Powell
* Date written: 1 Mar	Date Demo'd: 8 Mar
* This program switches the 1st row of a matrix
* with the last row, the second row with the 
* second to last row, and so on. This program
* also makes calls to subroutines.

* Constant Declarations: ************************
N	equ	3	;number of matrix rows
M	equ	4	;number of matrix columns
OUTA	equ	$FFB8	;outa buffalo subroutine
OUTSTRG	equ	$FFC7	;outstrg buffalo subroutine
OUTLHLF	equ	$FFB2	;outlhlf subroutine
OUTRHLF	equ	$FFB5	;outrhlf subroutine
OUTCRLF	equ	$FFC4	;outcrlf subroutine

* Variable Declarations
	org	$100
Matrix	fcb	$a1, $a2, $a3, $a4
	fcb	$b1, $b2, $b3, $b4
	fcb	$c1, $c2, $c3, $c4

len	rmb	2
swaps	rmb	1
temp	rmb	1

* Messages
msg1	fcc	"The original matrix is as follows:"
	fcb	$04
msg2	fcc	"The modified matrix is as follows:"
	fcb	$04


* Main ******************************************
	org	$b600
Main	lds	#$01FF	;init stack

	clra
	clrb
	ldaa	#N
	ldab	#M
	mul		;calculates the length of the matrix
	std	len

	ldd	#N
	ldx	#02
	idiv
	xgdx
	stab	swaps

	ldx	#MSG1	;load X with address of MSG1
	jsr	outstrg
	
	ldx	#Matrix
	pshx
	ldab	#M
	pshb
	ldaa	#N
	psha

	bsr	printmat

	bsr	swapmat

	ldx	#MSG2	;load X with address of MSG2
	jsr	outstrg

	bsr	printmat
	swi


* Subroutines: **********************************
* printmat:	prints all elements of the matrix

printmat jsr	outcrlf		;starts a new line to print matrix on
	
	ldx	#Matrix
	ldy	#0
new_col	ldab 	#M
samero	ldaa	0,X
	jsr	outlhlf
	ldaa	0,X
	jsr	outrhlf
	ldaa 	#$20
	jsr	outa
	inx
	iny
	decb
	bne	samero
	jsr	outcrlf
	cpy	len
	bne	new_col
	
	rts	

* swapmat:	swaps the first row for the last row, the second row for second-to-last row..etc.
swapmat	ldx	#Matrix
	ldd	len
	subd	#M
	abx
	ldy	#Matrix
nextrow	ldab	#M
samerow	ldaa	0,Y
	staa	temp
	ldaa	0,X
	staa	0,Y
	ldaa	temp	
	staa	0,X
	inx
	iny
	decb
	bne	samerow
	ldab	swaps
	ldaa	#M
	mul
	stab	temp
	xgdx
	subb	temp
	xgdx
	dec 	swaps
	ldab	swaps
	bne	nextrow
	rts