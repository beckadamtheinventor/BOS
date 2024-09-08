;@DOES Convert num to a base-10 string.
;@INPUT char *str_FromByte(char *dest, uint8_t num);
str_FromByte:
	pop bc,de,hl
	push hl,de,bc
	push de,de
	ex (sp),iy
	ld a,l
	or a,a
	sbc hl,hl
	ld l,a
	xor a,a
	ld e,a
	jr str_FromLong.long_to_str_100
