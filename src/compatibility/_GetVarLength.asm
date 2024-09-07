;@DOES return the length in bytes of a given variable in the VAT
;@INPUT HL = VAT pointer
;@OUTPUT HL = size. Cf set if failed.
_GetVarLength:
	ld de,(ti.pTemp)
	call _CpHLDE
	ret c
	ld a,(hl)
	cp a,ti.AppVarObj
	jr z,.file_like_type
	cp a,ti.ProgObj
	jr z,.file_like_type
	cp a,ti.ProtProgObj
	jr z,.file_like_type
	scf
	ret
.file_like_type:
	dec hl
	dec hl
	dec hl
	ld e,(hl)
	dec hl
	ld d,(hl)
	dec hl
	ld a,(hl)
	call _SetDEUToA
	ex hl,de
	ld hl,(hl)
	ex.s de,hl
	ret
