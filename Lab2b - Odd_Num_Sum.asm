* Program to compute the sum of all odd numbers in an array
* with 10 8-bit elements. the array is stored at memloc $00-09
* save the sum at memloc $20-21
* the index register [X] is used as the pointer to the array element.

N	equ	10
	
	org 	$00
array	fcb	11,13,54,34,67,97,71,87,63,51	;array elements

	org	$20
sum	rmb	2
	
	org	$b600
	ldaa	#$00
	staa	sum	;init sum to 0
	staa	sum+1	; "	
	ldx	#array	;point x to array[0]
loop	brclr	0,x $01 chkend	;is it an odd number?
	ldd	sum	;add the odd number to the sum
	addb	0,x	; "
	adca	#0	; "
	std	sum	; 
chkend	cpx	#array+n-1; are we at end of array?
	bhs	exit	;
	inx		;
	bra	loop	;
exit	swi