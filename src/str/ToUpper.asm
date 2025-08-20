
_toupper:
	ld hl,3
	add hl,sp
	ld l,(hl)
	ld a,l
	cp a,'a'
	ret c
	cp a,'z'+1
	ret nc
	and a,$E0 ; ~$20
	ld l,a
	ret
