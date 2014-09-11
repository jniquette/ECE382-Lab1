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


.data
Results:		.space	80

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


INPUT:		.byte	0x14, 0x11, 0x32, 0x22, 0x08, 0x44, 0x04, 0x11, 0x08, 0x55




;.text
;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

;start:
	;Initialize the InputPointer at the start of the input
	mov		#INPUT, 			InputPointer
	mov		#Results,			ResultsPointer

GetOperand1:
	;Get the first Operand
	mov.b	0(InputPointer), 	Operand1
	inc		InputPointer

GetOperation:
	;Get the Operation and Check if it is END_OP
	mov.b	0(InputPointer), 	Operation
	cmp		&END_OP, 			Operation
	jeq		holdingPattern

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
	mov		#0xFF,				0(Operand1)
	jmp		StoreResult

SubNumbers:
	;Subtract the Values
	sub.b	Operand2, 			Operand1
	jn		NegativeResult						;If the Result didn't overflow, then store the result
	jmp		StoreResult

	;If the result is negative,  per instructions
NegativeResult:
	mov		#0x00,				Operand1
	jmp		StoreResult

SetClear:
	; Increment RAM Pointer, Put 0x00, Increment RAM Pointer
	inc		ResultsPointer
	mov		#0,					0(ResultsPointer)
	inc		ResultsPointer
	jmp		GetOperand1

MultNumbers:
	; Multiply by powers of 2 (rotate left) then add the rest
	; This will result in an execution time of O(Log N)

StoreResult:
	mov		Operand1,			0(ResultsPointer)
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
