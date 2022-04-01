
_SetBCUToB:
	ld a,b
_SetBCUToA:
	push hl
	ld h,b
	ld l,c
	jr _SetDEUToA._SetHLUToA_popHL

_SetDEUToB:
	ld a,b
_SetDEUToA:
	push hl
	ex hl,de
._SetHLUToA_popHL:
	call _SetHLUToA
	pop hl
	ret

_SetHLUToB:
	ld a,b
_SetHLUToA:
	ld (ti.scrapMem),hl
	ld (ti.scrapMem+2),a
	ld hl,(ti.scrapMem)
	ret

