
_StrCopy:
	ld a,(hl)
	ld (de),a
	or a,a
	ret z
	inc hl
	inc de
	jr .
