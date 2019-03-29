* Bryan Powell
* Date written: 6 Feb	Date Demo'd: 8 Feb
* This is a program to compute the product of a 3-byte number (multiplicand) 
* stored at memory locations $00-$02 and a 1-byte number (multiplier) stored 
* at memory location $03. The product is stored at memory locations $04-$07.

	org $00
m	rmb 3	;multiplicand
n	rmb 1	;multiplyer
p	rmb 4	;product
p1	rmb 2	;1st step of multiplication
p2	rmb 2	;2nd step
p3	rmb 2	;3rd step

	org $100
	ldaa m+2	;load [A] with multiplicand lsb
	ldab n		;load [B] with multiplier
	mul
	stab p+3	;stores lsb of product
	staa p1		;stores p1 msb
	ldaa m+1	;loads mid-bit of m
	ldab n		;loads multiplier to [B]
	mul		;multiplies [A] and [B]
	stab p1+1	;stores result at low byte of p1
	std p2		;stores 2nd step
	ldaa m		;loads high bit of m to [A]
	ldab n		;loads multiplier to [B]
	mul		;multiplies [A] and [B]
	std p3		;stores 3rd step
	ldaa p1		;loads first intermediary step to [A]
	adda p2+1	;adds low byte of second step to [A]
	staa p+2	;stores mid-lo byte of product
	ldaa p2		;loads second intermediary step to [A]
	adca p3+1	;adds with carry the lo byte of step 3 to [A]
	staa p+1	;stores mid-hi byte of product
	ldaa p3		;loads third intermediary step to [A]
	adca #0		;adds the carry bit (if any) to the last step
	staa p		;stores high byte of product	
	swi		;program end