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
	subi	r26, 0x3F	; test subtract immediate instruction
	sbci	r26, 0x01	; 
	sbci	r26, 0x0F	;

; test bitwise operations 
	ldi		r24, 0x0F	; setup for the swap instruction
	swap	r24			; should be 0xF0
	ldi		r24, 0x50	; setup for swap instruction
	swap	r24			; should be 0x05

	; test status register sets and clears
	bset	7			; Set I flag
	bclr	7			; Clear I flag
	bset	6			; Set T flag
	bclr	6			; Clear T flag
	bclr	5			; Clear H flag
	bset	5			; Set H flag
	bclr	4			; Clear S flag
	bset	4			; Set S flag
	bset	3			; Set V flag
	bclr	3			; Clear V flag
	bclr	2			; Clear N flag
	bset	2			; Set N flag
	bset	1			; Set Z flag
	bclr	1			; Clear Z flag
	bset	0			; Set C flag
	bclr	0			; Clear C flag

	ldi		r26, 0x08	; Setup for BLD instruction
	bst	    r26, 3		; set the T flag
	bld		r26, 1		; set bit 1 in r26
	bst		r26, 0		; clear the T flag
	bld	    r26, 3		; clear bit 3 in r26
	 
; test F-block operations
	ldi		r24, 0x55	; setup for AND operation
	ldi		r26, 0xAA	;
	ldi		r28, 0x5A	;
	and		r24, r26	; have no bits in common
	and		r26, r28	; have four bits in common

	andi	r28, 0x5A	; should be same value
	andi	r28, 0xF5	; have two bits in common
	andi	r28, 0x0F	; have nothing in common

	ldi		r24, 0x0F	; setup for com
	com		r24			; flip bits
	ldi		r24, 0x53	; setup for com
	com		r24			; flip bits

	ldi		r24, 0x0F	; setup for xor
	ldi		r26, 0xAF	; 
	eor		r24, r26	; exclusive or

	ldi		r24, 0x0F	; setup for or
	ldi		r26, 0xF0	;
	or		r24, r26	; or registers

	ldi		r24, 0xA0	; setup for or
	or		r26, r24	; or registers
	
	ori		r24, 0xAF	; or immediate
	ori		r24, 0x00	; or immediate


; test shift rotate operations
	ldi		r24, 0x88	; setup for ASR
	asr		r24			; shift right preserve high bit
	asr		r24			; shift right again
	ldi		r24, 0x01	; setup for asr
	asr		r24			; shift out of low bit into carry

	ldi		r24, 0x81	; setup for lsr
	lsr		r24			;
	lsr		r24			;

	ldi		r24, 0x02	; setup for ror
	ror		r24			; rotate
	ror		r24			; rotate into carry
	ror		r24			; 

; test neg, inc, dec
	ldi		r24, 0x01	; setup for neg
	neg		r24			; should give 2's compliment
	inc		r24			; increment value
	dec		r24			; decrement value


; test word instuctions
	ldi		r26, 0xCF	; setup for adiw
	adiw	r27:r26, 0x3F	; add immediate

	ldi		r27, 0x02	; setup for sbiw
	ldi		r26, 0xFF	; 
	sbiw	r27:r26, 0x3F	;subtract immediate

	ldi		r27, 0x00	; 
	ldi		r26, 0x00	;
	sbiw	r27:r26, 0x3F;

; Test subtract with carry operations for Z flag
	bset	0			; Set C flag
	ldi		r24, 0x3F	; setup sbc
	ldi		r26, 0x3E	;
	sbc		r24, r26    ; Should not change Z flag

; Test additional add/sub operations
	ldi		r24, 0xBF	; prepare for add
	ldi		r26, 0xBF	;
	add		r24, r26	; should set V flag

	bset	0			; Set C flag
	ldi		r24, 0xFE	;
	ldi		r26, 0x01	;
	adc		r24, r26	; should be 0

	dec		r24			;
	dec		r24			; test wrap around

	ldi		r24, 0xFE	; 
	inc		r24
	inc		r24			; test wrap around

	ldi		r27, 0xFF	;
	ldi		r26, 0xFF	;
	adiw	r27:r26, 0x3F; test large numbers and zero flag

	ldi		r27, 0x00	;
	ldi		r26, 0x0F	;
	sbiw	r27:r26, 0x3;test sbiw where r27 is zero

    
    
    
    
	

	
