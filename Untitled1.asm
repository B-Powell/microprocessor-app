* Bryan Powell
* Date written: 19 Mar	Date Demo'd: 21 Mar
* This program evaluates the contents of an array
* It inspects each element and counts how many are
* even, odd, positive and negative. The final results
* are stored in mem locations $00-$03.


hprio	equ	$103c
mask	equ	$f5

	org	$0200
m	rmb 	1	;reserve 1 byte for m at beginning of external ram
n	rmb	1	;reserve 1 byte for n at next mem location
sum	rmb	1	;reserve 1 byte for sum at next mem loc

	org	$b600
	ldaa	#mask	;change hprio for internal read visibility
	staa	hprio
	ldaa	#5	;initialize m to 5
	staa	m
	ldaa	#4	;initialize n to 4
	staa	n
loop	ldaa	m	;load m into [A]
	ldab	n	;load n into [B]
	aba		;[A]+[B]=> [A]
	staa	sum	;stores [A] at sum
	bra	loop	;loop forever
	swi