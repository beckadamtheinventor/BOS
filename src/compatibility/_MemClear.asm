;@DOES Clear (Zero) BC bytes at HL
_MemClear:
	push de
	push hl
	pop de
	inc de
	xor a,a
	ld (hl),a
	ldir
	pop de
	ret

