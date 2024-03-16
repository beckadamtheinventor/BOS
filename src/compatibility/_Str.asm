
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
	ld c,a
	mlt bc
	cpir
	scf
	sbc hl,hl
	sbc hl,bc
	ex (sp),hl
	pop bc,af
	ret
	
	
	
