;@INPUT hl pointer to input byte
;@INPUT de pointer to output buffer
;@OUTPUT None
str_ByteToHexStr:
	ld a,(hl)
	rrca
	rrca
	rrca
	rrca
	call str_Nibble
	ld (de),a
	inc de
	ld a,(hl)
	call str_Nibble
	ld (de),a
	inc de
	ret
