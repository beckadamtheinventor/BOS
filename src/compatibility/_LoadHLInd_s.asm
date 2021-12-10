;@DOES load HL with 16-bit value at HL
_LoadHLInd_s:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jq _SetHLUTo0
