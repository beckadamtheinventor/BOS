;@DOES Unlocks flash
sys_FlashUnlock:
flash_unlock:
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
    ret
