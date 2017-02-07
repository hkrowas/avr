;
; ALU Instructions.asm
;
; Created: 2/3/2017 7:46:48 PM
; Author : Torkom
;


; Replace with your application code
start:

; test addition/subtraction instructions

	ldi     r26, 0xF0	;
	ldi     r24, 0x0F	;
	add     r26, r24	; regular add, r26 should have 0xFF
	ldi     r24, 0x1	; add one to overflow
	adc     r24, r26	; should set the carry flag, r24 = 0, C = 1
    ldi     r24, 0x3F   ; add directly to r24, r24 = 0x3F
	cp      r24, r26    ; zero flag should not be set 
    ldi     r26, 0x3F   ; subtract from r26, r26 = 0x3F
    cp      r24, r26    ; compare the same values
    cpi     r24, 0xFF   ; compare to immediate value 
    cpi     r24, 0x3F   ; compare immediate value with both being the same 
    ldi     r18, 0xFF   ; load 0xff into another register
    add     r24, r18    ; this should cause the carry flag to be set, r24 = 3E 
    cpc     r26, r24    ; this instruction should be equal and set the ZF 
	sub		r24, r26	; this instruction should test subtraction, r26 = 0x01
	sbc     r24, r26	; should subtract but also include the carry
	sbc		r24, r26	; carry is now 0 and the subtraction should be a regular subtraction
	sbiw	r26, 0x0F	; subtract immediate
	subi	r26, 0x3F	; this instruction also sets the H flag

; test bitwise operations 
	ldi		r24, 0x0F	; setup for the swap instruction
	swap	r24			; should be 0xF0
	

; test logical operations


; test F-block operations

	



    
    
    
    
	

	
