start:
test_adiw:
  ldi   r26, 0x54   ;
  ldi   r27, 0x21   ;
  adiw  X, 0x8      ; test add constant to word
  cpi   r26, 0x5c
  breq  b43
  call TestError    
  b43: cpi    r27, 0x21
  breq  test_sbiw	;
  call TestError    ;
test_sbiw:
  sbiw  X, 0x0c     ; test subtract from word
  cpi   r26, 0x50
  breq  b44
  call TestError    ;
  b44: cpi    r27, 0x21
  breq  test_add
  call TestError    ;
test_add:
  ldi   r16, 0
  ldi   r17, 58
  add   r16, r17      ; test add
  cp    r16, r17     ; r17 should be equal to r16
  breq  b1
  call TestError    ;
b1: brvs  b2          ; previous add should not overflow
  rjmp rel1
b2: call TestError    ;
rel1:  ldi   r17, 0x7f    ; set up overflow add
  ldi   r16, 0x7f
  add   r17, r16
  brvc  b3           ; branch if not set (i.e. overflow not detected)
  rjmp test_sub
b3:  call TestError    ;
test_sub:
  ldi   r16, 1
  ldi   r17, 1
  sub   r16, r17      ; check subtraction
  brne  b4
  rjmp test_adc
b4:  call TestError    ;
test_adc:
  sec               ; set carry flag to test adc
  adc   r16, r16
  cpi   r16, 1
  brne  b5
  rjmp test_subi
b5:  call TestError    ;
test_subi:
  subi  r16, 1       ; test subtraction by immediate
  brne  b6
  rjmp rel2
b6:  call TestError    ;
rel2:  sec
test_subc:
  sbc  r16, r16      ; test subtraction with carry
  cpi   r16, -1
  brne  b7
  rjmp test_subci
b7:  call TestError    ;
test_subci:
  sec               ; set carry to test subtraction by immediate with carry
  sbci  r16, 1
  cpi   r16, -3
  brne  b8
  rjmp test_and
b8:  call TestError    ;
test_and:
  ldi   r16, 0
  ldi   r17, 0xff
  and   r16, r17      ; test r1 & r16
  brne  b9
  rjmp rel3
b9:  call TestError    ;
rel3:  ldi   r16, 0xff
  and   r16, r17
  cpi   r16, 0xff
  brne  b10
  rjmp test_andi
b10:  call TestError    ;
test_andi:
  andi  r16, 0x00    ; test and by immediate
  brne  b11
  rjmp test_or
b11:  call TestError    ;
test_or:
  ldi   r16, 0
  ldi   r17, 0
  or    r16, r17      ; test or
  brne  b12
  rjmp rel4
 b12: call TestError    ;
 rel4: ldi   r17, 0x46
  or    r16, r17      ; test or
  cpi   r16, 0x46
  brne  b13
  rjmp rel5
  b13: call TestError    ;
  rel5: ldi   r17, 0xff
  or    r16, r17
  cpi   r16, 0xff
  brne  b14
  rjmp test_ori
  b14: call TestError    ;
test_ori:
  ldi   r16, 0
  ori   r16, 0x38    ; test or by immediate
  cpi   r16, 0x38
  brne  b15
  rjmp rel6
 b15: call TestError    ;
 rel6: eor   r16, r16      ; test exclusive or. r16 should be 0
  brne  b16
  rjmp test_com
  b16: call TestError    ;
test_com:
  com   r16          ; test one's complement
  cpi   r16, 0xff
  brne  b17
  rjmp rel7
  b17: call TestError    ;
  rel7: ldi   r16, 0x46
  com   r16
  cpi   r16, 0xB9
  brne  b18
  rjmp test_neg
  b18: call TestError    ;
test_neg:
  neg   r16          ; test two's complement
  cpi   r16, 0x47
  brne  b19
  rjmp rel8
  b19: call TestError    ;
  rel8: ldi   r16, 0
test_sbr:
  sbr   r16, 1       ; test set first bit of r16
  cpi   r16, 0x01
  brne  b20
  rjmp rel9
 b20: call TestError    ;
  rel9: sbr   r16, 0x80       ; test set last bit of r16
  cpi   r16, 0x81
  brne  b21
  rjmp test_cbr
  b21: call TestError    ;
test_cbr:
  cbr   r16, 1       ; test clear last bit of r16
  cpi   r16, 0x80
  cbr   r16, 0x80       ; test clear first bit of r16
  brne  b22
  rjmp test_inc
  b22: call TestError    ;
test_inc:
  ldi   r16, 0
  inc   r16          ; test increment
  cpi   r16, 1
  brne  b23
  rjmp test_dec
  b23: call TestError    ;
test_dec:
  dec   r16          ; test decrement
  brne  b24
  rjmp test_tst
  b24: call TestError    ;
test_tst:
  tst   r16      ; test tst
  brne  b25
  rjmp test_clr
 b25: call TestError    ;
test_clr:
  clr   r16          ; test set r16 to 0x00
  brne  b27
  rjmp test_ser
  b27: call TestError    ;
test_ser:
  ser   r16          ; test set r16 to 0xff
  cpi   r16, 0xff
  brne b28
  rjmp rel10
  b28: call TestError    ;
  rel10: ldi   r16, 0x23    ; Test data transfer instructions
test_sts_lds:
  sts   0x0021, r16  ;W 0x23 0x0021 test store and load direct
  lds   r16, 0x0021  ;R 0x21 0x0021
  ldi   r26, 0x43
  ldi   r27, 0x02
  st    X, r16       ;W 0x23 0x0243 test store and load indirect
  ld    r16, X       ;R 0x23 0x0243
  ldi   r28, 0x43
  ldi   r29, 0x02
  st    Y, r16       ;W 0x23 0x0243
  ld    r16, Y       ;R 0x23 0x0243
  ldi   r30, 0x43
  ldi   r31, 0x02
  st   Z, r16       ;W 0x23 0x0243
  ld    r16, Z       ;R 0x23 0x0243
  ldi   r16, 0x29
test_std_ldd:
  std   Y+5, r16     ;W 0x29 0x0248 test store and load indirect with displacement
  clr   r16
  ldd   r16, Y+5     ;R 0x29 0x0248
  st    Y+, r16      ;W 0x29 0x0243
  st    Y+, r16      ;W 0x29 0x0244
  ld    r16, -Y      ;R 0x29 0x0243
  ldi   r17, 0x54
  mov   r16, r17     ; test mov
  cpi   r16, 0x54
  brne  b29
  rjmp rel11
  b29: call TestError    ;
  rel11: ldi   r16, 0x32    ; test load immediate
  cpi   r16, 0x32
  ldi   r26, 0x5a   ; test move word (X = 0x865a)
  ldi   r27, 0x86
test_movw:
  movw  Y, X        ; Y = X = 0x8651
  cpi   r28, 0x5a
  brne  b30
  rjmp rel12
  b30: call TestError    ;
  rel12: cpi   r29, 0x86
  brne  b31
  rjmp test_rjmp
  b31: call TestError    ;
test_rjmp:
  rjmp rel13 		    ; testing relative jump
	call TestError  ; should not execute
	rel13: JMP testJump	; jump to address in memory
	call TestError  ; should skip over this

testJump:
	SEI				; set the interrupt flag
	BRIE test_Int	; tests to see if the interrupt flag is set
	call TestError  ; should not execute

test_Int:
	CLI				; clears the interrupt flag
	BRIE b32			; tests to see if the branch instruction is working
	BRID testIClr	; tests to see if the interrupt flag is cleared
	b32: call TestError  ; should not execute

testIClr:
	SEC				; sets the carry flag
	BRCS b33		; should not skip next line if carry is set
	call TestError	;
	b33: BRCS testCSet	; tests to see if carry is set
	call TestError  ; should not execute

testCSet:
	CLC				; clears the carry flag
	BRCS b34			; tests the branch instruction is working
	BRCC testCClr	; tests to see if the carry flag is cleared
	b34: call TestError  ; shoud not execute

testCClr:
	SEN				; sets the negative flag
	BRMI b35			; should not skip next line if negative is set
	call TestError  ;
	b35: BRMI testNSet	; tests to see if negative is set
	call TestError  ; should not execute

testNSet:
	CLN				; clears the negative flag
	BRMI b36			; tests the branch instruction is working
	BRPL testNClr	; tests to see if the negative flag is cleared
	b36: call TestError  ; shoud not execute

testNClr:
	SEV				; sets the overflow flag
	BRVS b37			; should not skip next line if overflow is set
	call TestError  ;
	b37: BRVS testVSet	; tests to see if overflow is set
	call TestError  ; should not execute

testVSet:
	CLV				; clears the overflow flag
	BRVS b38			; tests the branch instruction is working
	BRVC testVClr	; tests to see if the overflow flag is cleared
	b38: call TestError  ; shoud not execute

testVClr:
	BRLT b39			; Tests lower than but should not execute
	BRGE testGE		; N flag is cleared so this tests greater than or equal
	b39: call TestError  ; Should not execute

testGE:
	SEV				; Set the overflow flag
	SEN				; Set the negative flag
	SES				; Set sign flag
	BRGE b40			; Tests greater than or equal but should not execute
	BRLT testLT		; N flag is set so this tests lower than
	b40: call TestError  ; Sould not execute

testLT:
  	LDI R16, 2  	; setup the registers to test for CPC
  	LDI R17, 1
  	SEC				; set the carry flag
  	CPC R16, R17	; result should be 0 and set the zero flag
  	BRNE b41			; tests if result is not equal but should jump
  	BREQ testZset	; tests the brach if zero instruction
  	b41: call TestError  ; should not execute

testZSet:
	CLZ				; clears the zero flag
	BREQ b42			; tests the brach if equal instruction
	BRNE testZClr	; tests the branch if not equal instruction
	b42: call TestError  ; should not execute

testZClr:
	LDI R16, 0x82	; load 0b10000010 into R16 register to test LSL
	LSL R16			; this command should set the carry flag
	BRCS testLSLC	; should branch since carry should be set
	call TestError  				;should not be executed

testLSLC:
	CPI R16, 4		; this should test if the shift left actually worked
	BREQ LSLWorks	;
	call TestError  ; should not be executed

LSLWorks:
	SEC				; sets the carry flag
	ROL R16			; this should see if the rotate right thorugh carry works
	CPI R16, 9		; this sould be the result if the rotate worked
	BREQ ROLWorks	;
	call TestError  ; Should not be executed

ROLWorks:
	LDI	R16, 0x82	; setup with signed bit set
	ASR	R16			; sign bit should be set
	CPI R16, 0xC1	; check to see if only the right 7 bits shifted
	BREQ ASRWorks	;
	call TestError  ; should not be executed

ASRWorks:
	call TestGood   ; end of test

TestError:
  rjmp TestError   ;
TestGood:
  rjmp TestGood    ;