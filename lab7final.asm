REGBAS	EQU  $1000	;Defining constants associated with Port offsets
PORTB	EQU  $04
PORTC	EQU  $03
DDRC	EQU  $07
IOMASK	EQU  $F0	;Mask for DDRC register

	ORG  $0000
ONE	FCB  $cf	;Number for each light up configuration
TWO	FCB  $92
THREE	FCB  $86
A	FCB  $88
FOUR	FCB  $cc
FIVE	FCB  $a4
SIX	FCB  $a0
B	FCB  $e0
SEVEN	FCB  $8f
EIGHT	FCB  $80
NINE	FCB  $8c
C	FCB  $f2
STAR	FCB  $fe ;makes a '-'
ZERO	FCB  $81
POUNT	FCB  $98 ;makes a 'p'
D	FCB  $c2

ROW	RMB  1		;Reserving room for the counters - Row index of pressed key
COL	RMB  1		;Column index of pressed key


	ORG  $B600	;count down from 9-0
	LDS  #$01FF
	LDAB #2		;Loading B with two to make the counter go twice

RECOUNT	LDY  #ZERO	;Y = address at 'zero'

TEST	JSR  DISP_DATA
	JSR  DELAY

	CMPA ZERO	;Countin 0-1
	BEQ  G_ONE	

	CMPA THREE	;Count 3-4
	BEQ  G_FOUR

	CMPA SIX	;Count 6-7
	BEQ  G_SEVEN

	CMPA NINE	;Count 9-0
	BEQ  G_ZERO

	INY		;incrementing y if the numbers aren't the ones above
	BRA  TEST

G_ONE	LDY  #ONE	
	BRA  TEST

G_FOUR	LDY  #FOUR
	BRA  TEST

G_SEVEN	LDY  #SEVEN
	BRA  TEST

G_ZERO	DECB
	BNE  RECOUNT

	LDX  #REGBAS	;Makes the screen cleared
	LDAA #$FF	;after the countdown is finished
	STAA PORTB,X	


	LDX  #REGBAS	;Setting DDR Register to have 
	LDAA #IOMASK	;The first 4 MSB to be inputs
	STAA DDRC,X	;The last 4 LSB to be outputs

N_KEY	BSR  SCAN_KEY	;Scan keypad for a key to be pressed
	BSR  WHICH_KEY	; if a key is detected, find row and column
	BSR  DISP_DATA	; branch to display the key pressed 			
	BRA  N_KEY	

	SWI
	


DELAY	PSHA		;Delay Subroutine
	LDAA #10
REDO	LDX  #8283	
AGAIN	NOP		
	DEX		
	BNE  AGAIN	
	DECA		
	BNE  REDO	
	PULA
	RTS


DISP_DATA	LDX  #REGBAS
		LDAA 0,Y	;Loading Y to point to 7-segment display content
		STAA PORTB,X	
		RTS


SCAN_KEY	CLR  ROW
		CLR  COL

COL_1	LDAB #%00000111		;Checking first column
	STAB PORTC,X
	BRA  ROWCHK

COL_2	INC  COL		;Check second column
	LDAB #%00001011
	STAB PORTC,X
	BRA  ROWCHK

COL_3	INC  COL		;Check third column
	LDAB #%00001101
	STAB PORTC,X
	BRA  ROWCHK

COL_4	INC  COL		;Check fourth column
	LDAB #%00001110
	STAB PORTC,X

ROWCHK	CLR   ROW
	BRCLR PORTC,X,%10000000,DONE	;Check 1st row
	INC   ROW
	BRCLR PORTC,X,%01000000,DONE	;Check 2nd row
	INC   ROW
	BRCLR PORTC,X,%00100000,DONE ;Check 3rd row
	INC   ROW
	BRCLR PORTC,X,%00010000,DONE	;Check 4th row
	
	LDAA  COL		;Move to the next column
	BEQ   COL_2	; "
	DECA		; "
	BEQ   COL_3	; "
	DECA		; "
	BEQ   COL_4	; "

	BRA   SCAN_KEY	;Holds the key until another key is pressed
			
DONE	RTS		;Return to main program


WHICH_KEY	LDAA ROW		; Load A with Road index
		LDAB #4		;+ Column
		MUL		;=Offset away from list base depending on the row
		ADDB COL
	
		LDY  #$0000
		ABY		;Y is the offset away from list base
		RTS
