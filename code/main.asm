;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
                                            ; Constants
;-------------------------------------------------------------------------------
ADD_OP:		.equ	0x11
SUB_OP:		.equ	0x22
MUL_OP:		.equ	0x33
CLR_OP:		.equ	0x44
END_OP:		.equ	0x55

;-------------------------------------------------------------------------------
                                            ; Variables
;-------------------------------------------------------------------------------
Operand1:		.equ	r4
Operand2:		.equ	r5
Operation:		.equ	r6
InputPointer:	.equ	r7
ResultsPointer:	.equ	r8
MultCount:		.equ	r11
Accumulator:	.equ	r12

;	Required Functionality
;INPUT:		.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x44, 0x22, 0x22, 0x22, 0x11, 0xCC, 0x55
;	B Functionality
;INPUT:		.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55
;	A Functionality
INPUT:		.byte	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

start:
	;Initialize the InputPointer at the start of the input and the ResultsPointer at
	; the start of RAM (0x0200)
	mov		#INPUT, 			InputPointer
	mov		#0x200,				ResultsPointer

GetOperand1:
	;Get the first Operand
	mov.b	0(InputPointer), 	Operand1
	inc		InputPointer
	mov.b	Operand1,			0(ResultsPointer)


GetOperation:
	;Get the Operation and Check if it is END_OP or CLR_OP
	mov.b	0(InputPointer), 	Operation
	cmp		&END_OP, 			Operation
	jeq		holdingPattern
	cmp		#CLR_OP, 			Operation
	jeq		SetClear

	;Get Operand 2
	inc 	InputPointer
	mov.b	0(InputPointer),	Operand2
	inc		InputPointer

	;jump to the Proper Operation
	cmp		#ADD_OP, 			Operation
	jeq		AddNumbers
	cmp		#SUB_OP,			Operation
	jeq		SubNumbers
	cmp		#CLR_OP, 			Operation
	jeq		SetClear
	cmp		#MUL_OP, 			Operation
	jeq		MultNumbers

	;If it isn't an operation, set an error code of 0x99 and go to the holding pattern
	mov		#0x99,				Operation
	jmp		holdingPattern

;-------------------------------------------------------------------------------
                                            ; Subroutines
;-------------------------------------------------------------------------------

AddNumbers:
	;Add the two values together
	add.b	Operand2, 			Operand1
	jnc		StoreResult						;If the Result didn't overflow, then store the result

	;If the result overflowed, store 0xFF per instructions
	mov		#0xFF,				Operand1
	jmp		StoreResult

SubNumbers:
	;Subtract the Values
	sub.b	Operand2, 			Operand1
	jn		NegativeResult						;If the Result didn't overflow, then store the result
	jmp		StoreResult

	;If the result is negative, store 0x00 per instructions
NegativeResult:
	mov		#0x00,				Operand1
	jmp		StoreResult

SetClear:
	; Increment RAM Pointer, Put 0x00, Increment RAM Pointer
	;inc		ResultsPointer
	mov.b	#0,					0(ResultsPointer)
	inc		ResultsPointer
	inc		InputPointer
	jmp		GetOperand1

MultNumbers:
	; Multiply by powers of 2 (rotate left) then add the rest
	; This will result in an execution time of O(Log N)
	; Whichever operand is smaller will be the counter
	cmp		Operand1, 			Operand2
	jge		useOp1AsCounter
;	mov		Operand2, 			MultCounter
	jmp		MultStep2

useOp1AsCounter:
;	mov		Operand1, 			MultCounter
	push	Operand1
	mov 	Operand2,			Operand1
	pop		Operand2

MultStep2:	;Find powers of two and non-power of 2 multiplicants
	; Operand 1 (thing to add) < Operand 2
	; See if the Operand2 is a power of two and rotate the answer (MultRotCounter)
	; Otherwise add 1 to the MultAddCounter to add extras later
	; Ex: If Operand 2 is #10, then it's 0b1010, so rotate three times, add 2 times
	; Ex2: If Operand 2 is #55, then it's 0b110111, so rotate 5 times, add 5
	; and add 2.

	; Initialize Accumulator to 0 and count to 8 (for 8 bit);
	mov		#0,					Accumulator
	mov		#8,					MultCount

MultLoop:
	; See if we've reached all 8 bits
	cmp		#0,					MultCount
	jeq		DoneMultiplying

	; Shift Op2 Right and Check for carry
	rrc		Operand2
	jnc		DoNotAdd
	add		Operand1,			Accumulator

DoNotAdd:
	;	Before Rotating, See if Op1 >= 0x100 and will overflow
	cmp		#0x100,				Operand1
	jge		Overflow
	rla		Operand1		;Check here for overflow
;	bit		#0xfeff,			r2	;Test Status Bits for Overflow (V)
;	jnz		Overflow
	dec.b	MultCount
	jmp		MultLoop


Overflow:
	; If carry bit, then the result > 255, so output FF as answer
	mov.b	#255, Operand1
	jmp		StoreResult

DoneMultiplying:
	add		Accumulator,		Operand1
	; Fall to StoreResult

StoreResult:
	mov.b	Operand1,			0(ResultsPointer)
	inc		ResultsPointer
	jmp 	GetOperation


holdingPattern:
			jmp					holdingPattern

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
