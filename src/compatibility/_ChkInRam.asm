
_ChkInRam:
	push hl
	ld hl,$D00000
	or a,a
	sbc hl,de
	ccf
	sbc a,a
	pop hl
	ret
