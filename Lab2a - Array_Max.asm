* Finds the max element of an array and stores it at mem location $20

N	equ	10	;array count

	org	$00
array	fcb	3,24,15,74,4,10,13,12,9,28

	org	$b600
	ldaa	array	;set array[0] as the temp max
	ldab	#1	;loop index = 1
loop	ldx	#array	;point[X] to array[0]
	abx		;computes the address of array[i]
	cmpa	0,x	;compares temp max to next element in array
	bhs	chkend	;checks to update the array max
	ldaa	0,x	;updates the temp array max
chkend	cmpb	#N-1	;compares loop index with loop limit
	beq	exit	;checks to see if whole array has been looked at
	incb		;increment loop index
	bra	loop
exit	staa	$20	;saves the array max at memloc $20
	swi		;terminates program