
_StrCopy:
	ld a,(hl)
	ld (de),a
	or a,a
	ret z
	inc hl
	inc de
	jr .

; compare B bytes from data at HL and DE
_StrCmpre:
	ld a,(de)
	sub a,(hl)
	ret nz
	inc hl
	inc de
	djnz .
	ret

; compare strings HL and DE
; stop at null terminator without comparing
_StrCmpre0:
	ld a,(de)
	sub a,(hl)
	ret nz
	or a,(hl)
	ret z
	inc de
	inc hl
	jr .

; return length of string HL in BC
_StrLength:
	push af,hl
	xor a,a ; A = 0
	ld c,a
	mlt bc  ; BC = ? * 0 --> 0
	cpir
	scf
	sbc hl,hl
	sbc hl,bc
	ex (sp),hl
	pop bc,af
	ret
