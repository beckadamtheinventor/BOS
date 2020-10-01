;@DOES load DE with 16-bit value at HL, advancing DE+=2
_LoadDEInd_s:
	ld de,0
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ret
