;@DOES Clear (Zero) BC bytes at HL
_MemClear:
	push de
	xor a,a
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	pop de
	ret

