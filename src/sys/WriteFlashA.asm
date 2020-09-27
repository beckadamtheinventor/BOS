;@DOES write a byte from A to flash at address DE
;@INPUT HL, DE, BC
sys_WriteFlashA:
	ld hl,$F8
	push hl
	push af
	ld	a,$8c
	out0	($24),a
	ld	c,4
	in0	a,(6)
	or	c
	out0	(6),a
	out0	($28),c
	pop af
	ex hl,de
	and a,(hl)
	ex hl,de
	jp $2E8


