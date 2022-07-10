
_Zero16D:
	ld b,16
_ClrLP:
	ld (hl),0
	inc hl
	djnz _ClrLP
	ret
