
;@DOES load DE with 24-bit value at HL, advancing HL+=3
_LoadDEInd:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ret

;@DOES load DE with 16-bit value at HL, advancing HL+=2
_LoadDEInd_s:
	ld de,0
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ret
