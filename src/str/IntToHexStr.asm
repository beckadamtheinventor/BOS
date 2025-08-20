;@DOES Convert a 32-bit unsigned integer to a string
;@INPUT char* str_IntToHexStr(char* dest, uint32_t num);
;@OUTPUT pointer to dest
str_IntToHexStr:
	push iy
	ld iy,0
	add iy,sp
	lea hl,iy+9
	ld de,(iy+6)
	ld a,b
.incloop:
	inc hl
	djnz .incloop
	ld b,a
.loop:
	call str_ByteToHexStr.entry_dec_hl
	djnz .loop
	xor a,a
	ld (de),a
	ld hl,(iy+6)
	pop iy
	ret
