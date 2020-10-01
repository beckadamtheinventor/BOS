;@DOES Unlocks flash
sys_FlashUnlock:
flash_unlock:
	di
	in0 a,($06)
	set 2,a
	out0 ($06),a
	ld a,$04
	di
	jr $+2
	di
	rsmix
	im 1
	out0 ($28),a
	in0 a,($28)
	bit 2,a

	; ld	a,$8c
	; out0	($24),a
	; ld	c,4
	; in0	a,(6)
	; or	c
	; out0	(6),a
	; out0	($28),c
	ret
