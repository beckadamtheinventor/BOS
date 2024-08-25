
_FindFreeArcSpot:
	call _ArcChk
	add hl,bc
	xor a,a
	sbc hl,bc
	adc a,a
	ret
