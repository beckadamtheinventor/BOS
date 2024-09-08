;@DOES Convert num to a base-10 string.
;@INPUT char *str_FromInt(char *dest, unsigned int num);
str_FromInt:
	pop bc,de,hl
	push hl,de,bc
	push de,de
	ex (sp),iy
	xor a,a
	ld e,a
	jr str_FromLong.long_to_str_10m