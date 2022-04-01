
_SetBCUTo0:
	push af
	ld a,b
	ld b,1
	mlt bc
	ld b,a
	pop af
	ret

_SetDEUTo0:
	push hl
	ex.s hl,de
	ex hl,de
	pop hl
	ret

_SetHLUTo0:
	push de
	ex.s hl,de
	ex hl,de
	pop de
	ret
