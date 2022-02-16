;@DOES Clear (Zero) BC bytes at HL
_MemClear:
	xor a,a
;@DOES Set BC bytes at HL to A
_MemSet:
	push de
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	pop de
	ret

