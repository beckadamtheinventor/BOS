;@DOES write BC bytes to flash from HL to DE.
;@INPUT HL, DE, BC
sys_WriteFlash:
	push hl
	ld hl,$F8
	ex (sp),hl
	push bc
	ld	a,$8c
	out0	($24),a
	ld	c,4
	in0	a,(6)
	or	c
	out0	(6),a
	out0	($28),c
	pop bc
	jp $2E0
