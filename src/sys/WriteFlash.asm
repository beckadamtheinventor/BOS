;@DOES write BC bytes to flash from HL to DE.
;@INPUT HL, DE, BC
;@OUTPUT DE points to byte following written data
sys_WriteFlash:=$2E0
	; push bc
	; ld	a,$8c
	; out0	($24),a
	; ld	c,4
	; in0	a,(6)
	; or	c
	; out0	(6),a
	; out0	($28),c
	; pop bc
	; jp $2E0
