
_SetBCUToB:
	ld a,b
_SetBCUToA:
	push hl
	ld h,b
	ld l,c
	call _SetHLUToA
	ex (sp),hl
	pop bc
	ret

_SetDEUToB:
	ld a,b
_SetDEUToA:
	push hl
	ex hl,de
	call _SetHLUToA
	ex hl,de
	pop hl
	ret

_SetHLUToB:
	ld a,b
_SetHLUToA:
	ld (ti.scrapMem),hl
	ld (ti.scrapMem+2),a
	ld hl,(ti.scrapMem)
	ret

