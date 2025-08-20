;@DOES Convert signed 24-bit integer to a base-10 string.
;@INPUT char *str_IntToStr(char *dest, int num);
;@OUTPUT pointer to dest.
str_IntToStr:
	pop bc,de,hl
	push hl,de,bc
	push de,de
	ex (sp),iy
	xor a,a
	ld e,a
	jr str_LongToStr.10m