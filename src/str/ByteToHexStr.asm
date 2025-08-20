str_ByteToHexStr.entry_dec_hl:
	dec hl
;@INPUT hl pointer to input byte
;@INPUT de pointer to output buffer
;@OUTPUT None
str_ByteToHexStr:
	ld a,(hl)
	rrca
	rrca
	rrca
	rrca
	call osrt.nibble
	ld (de),a
	inc de
	ld a,(hl)
	call osrt.nibble
	ld (de),a
	inc de
	ret
