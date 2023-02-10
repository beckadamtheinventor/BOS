
_toupper:
	ld hl,6
	add hl,sp
	ld a,(hl)
	cp a,'a'
	ret c
	cp a,'z'+1
	ret nc
	and a,$E0 ; ~$20
	ret
