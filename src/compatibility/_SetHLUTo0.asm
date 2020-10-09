;@DOES Sets the top byte of HL to zero.
_SetHLUTo0:
	push de
	ex hl,de
	ex.s hl,de
	pop de
	ret
