
_tolower:
	ld hl,3
	add hl,sp
	ld l,(hl)
	ld a,l
	cp a,'A'
	ret c
	cp a,'Z'+1
	ret nc
	or a,$20
	ld l,a
	ret
