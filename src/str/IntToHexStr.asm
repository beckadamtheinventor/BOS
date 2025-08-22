;@DOES Convert a 24-bit unsigned integer to a string
;@INPUT char* str_IntToHexStr(char* dest, unsigned int num);
;@OUTPUT pointer to dest
str_IntToHexStr:
	call ti._frameset0
	lea hl,ix+9
	ld de,(ix+6)
	ld b,3
.entry_b:
	ld a,b
.incloop:
	inc hl
	djnz .incloop
	ld b,a
.loop:
	dec hl
	call str_ByteToHexStr
	djnz .loop
	xor a,a
	ld (de),a
	ld hl,(ix+6)
	pop ix
	ret
