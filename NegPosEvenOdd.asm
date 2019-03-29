* Bryan Powell
* Date written: 16 Feb	Date Demo'd: 22 Feb
* This program evaluates the contents of an array
* It inspects each element and counts how many are
* even, odd, positive and negative. The final results
* are stored in mem locations $00-$03.

N 	equ 10

	org $00
nco	rmb 1		;negative count
pco	rmb 1		;positive count
eco	rmb 1		;even count
oco	rmb 1		;odd count

	org $100
array	rmb N

	org $b600

	clr nco		;clears the counter variables
	clr pco
	clr eco
	clr oco
			
	ldx #array		;counter for loop
loop	brset 0,X %10000000 min	;branch to negative incrementer
	inc pco			;increments positive counter
	bra evenodd		;branches to next condition test
min	inc nco			;increments negative counter
evenodd	brset 0,X %00000001 odd	;branch to test if even or odd
	inc eco			;increments even counter	
	bra check		;branches to end of loop test
odd	inc oco			;increments odd counter	
check	inx			;increments loop counter
	cpx #array+N		;test loop counter for value against N
	bne loop		;branches back to start of the loop
	
	swi			;program end