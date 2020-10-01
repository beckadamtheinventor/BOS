;@DOES Sets the top byte of HL to zero.
_SetHLUTo0:
	push de
	ex.s hl,de
	ex hl,de
	pop de
	ret
