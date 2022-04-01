
;@DOES return Zf if [HL-3] == 0xFFFFFF else return result of HL = HL-3 - [HL-3]
_LoadDEIndFlash:
	dec hl
	dec hl
	dec hl
	ld de,(hl)
	scf
	sbc hl,hl
	or a,a
	sbc hl,de
	ret z
	add hl,de
	or a,a
	sbc hl,de
	ret

