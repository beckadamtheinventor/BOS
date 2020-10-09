;@DOES Clear (Zero) BC bytes at HL
_MemClear:
	push de
	push hl
	pop de
	inc de
	ld (hl),0
	ldir
	pop de
	ret

