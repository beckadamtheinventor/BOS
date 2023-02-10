
_tolower:
	ld hl,6
	add hl,sp
	ld a,(hl)
	cp a,'A'
	ret c
	cp a,'Z'+1
	ret nc
	or a,$20
	ret
