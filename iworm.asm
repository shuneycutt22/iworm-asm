;ECE 109 001 Fall 2019
;Sam Huneycutt (shhuneyc)
;created 8 October 2019
;Program 2: Etch-A-Sketch program
;	allows the user to draw lines on the screen using the WASD keys
;	change line color using RGBY and space (white)
;	the screen can be cleared using the return key
;
;
;	the cursor is 2px by 2px
;	cursor position is defined by the address of the top-left pixel
;
;	the Pennsim screen is 128 pixels wide and 124 lines tall
;
;
;	This program operates on the principles of subroutines
;	However, this program does not use the JSR or JSRR command
;

	.ORIG x3000
;
;the program will first clear the screen
;
CLEAR	AND R0, R0, 0			;set R0 to 0
	LD R1, SCREEN			;get the starting address of video memory
	LD R2, PIXELS			;get the number of locations in video memory
LOOP	STR R0, R1, 0			;store 0 into the video memory location
	ADD R1, R1, #1			;increment location address
	ADD R2, R2, #-1			;decrement location counter
	BRp LOOP			
	LEA R4, DRAW			;load DRAW subroutine address in R4
	LEA R5, INPUT			;load INPUT routine address in R5
	LD R6, COLOR			;load color into R6 (intial color white)
	JMP R4				;go to DRAW subroutine (draw the cursor after clearing the screen)


INPUT	LD R3, POS			;load cursor position from memory (Allows the cursor position to be seen in Pennsim while using program)
	GETC				;get character from user
	LD R1, NEGW			;compare char to w
	ADD R1, R1, R0
	BRz UP				;go to UP subroutine if comparison true
	LD R1, NEGS			;compare char to s
	ADD R1, R1, R0
	BRz DOWN			;go to DOWN subroutine if comparison true
	LD R1, NEGA			;compare char to a
	ADD R1, R1, R0
	BRz LEFT			;go to LEFT subroutine if comparison true
	LD R1, NEGD			;compare char to d
	ADD R1, R1, R0
	BRz RIGHT			;go to RIGHT subroutine if comparison true
	LD R1, NEGR			;compare char to r
	ADD R1, R1, R0
	BRz RED				;go to RED subroutine if comparison true
	LD R1, NEGG			;compare char to g
	ADD R1, R1, R0
	BRz GREEN			;go to GREEN subroutine if comparison true
	LD R1, NEGB			;compare char to b
	ADD R1, R1, R0
	BRz BLUE			;go to BLUE subroutine if comparison true
	LD R1, NEGY			;compare char to y
	ADD R1, R1, R0
	BRz YELLOW			;go to YELLOW subroutine if comparison true
	LD R1, NEGSP			;compare char to space
	ADD R1, R1, R0
	BRz WHITE			;go to WHITE subroutine if comparison true
	LD R1, NEGQ			;compare char to q
	ADD R1, R1, R0
	BRz BREAK			;go to BREAK subroutine if comparison true		
	ADD R1, R0, #-10		;compare char to return (linefeed)
	BRz CLEAR			;go to CLEAR subroutine if comparison true
	BRnp INPUT			;if no comparison true, run INPUT subroutine again

;
;The UP subroutine must keep the cursor from going off the screen at the top
;
UP	LD R0, POS			;load cursor position from memory
	LD R1, AND2			;load value xFF00 for bit comparison
	LD R2, TESTUP			;load x4000 (2's complement of xC000)
	;if cursor address begins with xC0, then cursor should not move up
	AND R3, R1, R0			;compare position to xFF00 (discards last 8 bits of position)
	;if cursor address begins with xC0, result in R3 will be xC000
	ADD R3, R3, R2			;add result to x4000 (2's complement of xC000)
	BRz INPUT			;if result zero (comparison true), go to INPUT subroutine
	LD R1, UP2			;load value -256 from memory
	ADD R0, R1, R0			;decrement cursor position by 256 (2 lines, 1 cursor row)
	ST R0, POS			;store new position to memory
	JMP R4				;go to DRAW subroutine

;
;The DOWN subroutine must keep the cursor from going off the screen at the bottom
;
DOWN	LD R0, POS			;load cursor position from memory
	LD R1, AND2			;load value xFF00 for bit comparison
	LD R2, TESTDN			;load x0300 (2's complement of xFD00)
	;if cursor address begins with xFD, then cursor should not move down
	AND R3, R1, R0			;compare position to xFF00 (discards last 8 bits of position)
	;if cursor address begins with xFD, result in R3 will be xFD00
	ADD R3, R3, R2			;add result to x0300 (2's complement of xFD00)
	BRz INPUT			;if result zero (comparison true), go to INPUT subroutine
	LD R1, DOWN2			;load value 256 from memory
	ADD R0, R1, R0			;increment cursor position by 256 (2 lines, 1 cursor row)
	ST R0, POS			;store new position to memory
	JMP R4				;go to DRAW subroutine

;
;The LEFT subroutine must keep the cursor from going off the screen at the left
;
LEFT	LD R0, POS			;load cursor position from memory
	LD R1, AND1			;load value x00FF for bit comparison
	;if cursor address ends with x00, then cursor should not move left 
	AND R3, R1, R0			;compare position to x00FF (discards first 8 bits of position)
	;if cursor address ends with x00, result in R3 will be x0000
	BRz INPUT			;if result zero (comparison true), go to INPUT subroutine
	ADD R0, R0, #-2			;decrement cursor position by 2 (2 pixels, 1 cursor block)
	ST R0, POS			;store new position to memory
	JMP R4				;go to DRAW subroutine

;
;The RIGHT subroutine must keep the cursor from going off the screen at the right
;
RIGHT	LD R0, POS			;load cursor position from memory
	LD R1, AND1			;load value x00FF for bit comparison
	LD R2, TESTR			;load value xFF82 (2's complement of x007E)
	;if cursor address ends with x7E, then cursor should not move right
	AND R3, R1, R0			;compare position to x00FF (discards first 8 bits of position)
	;if cursor address ends with x7E, result in R3 will be x007E
	ADD R3, R3, R2			;add result to xFF82 (2's complement of x007E)
	BRz INPUT 			;if result zero (comparison true), go to INPUT subroutine
	ADD R0, R0, 2			;increment cursor position by 2 (2 pixels, 1 cursor block)
	ST R0, POS			;store new position to memory
	JMP R4				;go to DRAW subroutine

;
;The cursor is 2px by 2px 
;the color code must be stored into all 4 locations
;
DRAW	LD R0, POS			;load cursor position from memory
	LD R6, COLOR			;load current color
	STR R6, R0, 0			;store color to top-left pixel of cursor
	STR R6, R0, #1			;store color to top-right pixel of cursor
	LD R1, DOWN1			;load value 128 (1 line)
	ADD R2, R0, R1			;increment position 1 line
	STR R6, R2, 0			;store color to bottom-left pixel of cursor
	STR R6, R2, #1			;store color to bottom-right pixel of cursor
	JMP R5				;go to INPUT

;
;after changing color, the new color must be drawn to the current cursor location
;the DRAW subroutine will be run after changing color code
;

RED	LD R6, COLR			;load color code for RED into R6
	ST R6, COLOR			;store current color
	JMP R4				;go to DRAW subroutine

GREEN	LD R6, COLG			;load color code for GREEN into R6
	ST R6, COLOR			;store current color
	JMP R4				;go to DRAW subroutine
	
BLUE	LD R6, COLB			;load color code for BLUE into R6
	ST R6, COLOR			;store current color
	JMP R4				;go to DRAW subroutine

YELLOW	LD R6, COLY			;load color code for YELLOW into R6
	ST R6, COLOR			;store current color
	JMP R4				;go to DRAW subroutine

WHITE	LD R6, COLW			;load color code for WHITE into R6
	ST R6, COLOR			;store current color
	JMP R4				;go to DRAW subroutine

BREAK	HALT				;halt execution


NEGW	.FILL	#-119			;w ascii comparison value
NEGS	.FILL	#-115			;s ascii comparison value
NEGA	.FILL	#-97			;a ascii comparison value
NEGD	.FILL	#-100			;d ascii comparison value
NEGR	.FILL	#-114			;r ascii comparison value
NEGG	.FILL	#-103			;g ascii comparison value
NEGB	.FILL	#-98			;b ascii comparison value
NEGY	.FILL	#-121			;y ascii comparison value
NEGSP	.FILL	#-32			;space ascii comparison value
NEGQ	.FILL	#-113			;q ascii comparison value
UP2	.FILL	#-256			;relative position 2 lines above
DOWN1	.FILL	#128			;relative position 1 line below
DOWN2	.FILL	#256			;relative position 2 lines below
COLOR	.FILL	x7FFF			;color variable  (inital color white)
COLR	.FILL	x7C00			;RED color code
COLG	.FILL	x03E0			;GREEN color code
COLB	.FILL	x001F			;BLUE color code
COLY	.FILL	x7FED			;YELLOW color code
COLW	.FILL	x7FFF			;WHITE color code
POS	.FILL	xDF40			;cursor position (initial position 0xDF40 coordinates (x,y)=(64,62))
SCREEN	.FILL	xC000			;video memory starting address
PIXELS	.FILL	x3DFF			;number of video memory locations
AND1	.FILL	x00FF			;bit comparison value 1
AND2	.FILL	xFF00			;bit comparison value 2
TESTR	.FILL	xFF82			;right-wall test value
TESTUP	.FILL	x4000			;top-wall test value
TESTDN	.FILL	x0300			;bottom-wall test value

.END