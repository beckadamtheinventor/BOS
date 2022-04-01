
_StrCopy:
	ld a,(hl)
	ld (de),a
	or a,a
	ret z
	inc hl
	inc de
	jr .


_StrCmpre:
	ld a,(de)
	cp a,(hl)
	ret nz
	inc hl
	inc de
	djnz .
	ret

_StrLength:
	push af,hl
	xor a,a
	sbc hl,hl
	ld c,a
	mlt bc
	cpir
	sbc hl,bc
	dec hl
	ex (sp),hl
	pop bc,af
	ret
	
	
	
