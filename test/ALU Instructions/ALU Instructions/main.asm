;
; ALU Instructions.asm
;
; Created: 2/3/2017 7:46:48 PM
; Author : Torkom
;


; Replace with your application code
start:

; test addition/subtraction instructions

	ldi     r16, 0xF0	;
	ldi     r17, 0x0F	;
	add     r16, r17	; regular add, R16 should have 0xFF
	ldi     r17, 0x1	; add one to overflow
	adc     r17, r16	; should set the carry flag, R17 = 0, C = 1
    adiw    r17, 0x3F   ; add directly to r17, r17 = 0x3F
    cp      r17, r16    ; zero flag should not be set 
    sbiw    r16, 0xC0   ; subtract from r16, r16 = 0x3F 
    cp      r17, r16    ; compare the same values
    cpi     r17, 0xFF   ; compare to immediate value 
    cpi     r17, 0x3F   ; compare immediate value with both being the same 
    ldi     r18, 0xFF   ; load 0xff into another register
    add     r17, r18    ; this should cause the carry flag to be set, r17 = 3E 
    cpc     r16, r17    ; this instruction should be equal and set the ZF 
    
    
    
    
	

	
