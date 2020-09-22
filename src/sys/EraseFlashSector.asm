;@DOES Erase flash sector
;@INPUT A sector to erase
;@DESTROYS All
;@NOTE calls boot routine $2DC
sys_EraseFlashSector:
	ld bc,$F8
	push bc
	ld	a,$8c
	out0	($24),a
	ld	c,4
	in0	a,(6)
	or	c
	out0	(6),a
	out0	($28),c
	jp $2DC
