;@DOES Unlocks flash.
;;@NOTE Resets the calc if not currently in elevated mode.
sys_FlashUnlock:
flash_unlock:
	push af
	ld a,$8C
	out0 ($24),a
	in0 a,($06)
	set 2,a
	out0 ($06),a
	ld a,4
	out0 ($28),a

	; in0 a,($06)
	; set 2,a
	; out0 ($06),a
	; ld a,$04
	; di
	; jr $+2
	; di
	; rsmix
	; im 1
	; out0 ($28),a
	; in0 a,($28)
	; bit 2,a

	; ld	a,$8c
	; out0	($24),a
	; ld	c,4
	; in0	a,(6)
	; or	c
	; out0	(6),a
	; out0	($28),c

;	call sys_CheckElevated ;check if we're elevated
;	jr z,.lock_and_reset
	pop af
	ret

;.lock_and_reset:
;	call sys_FlashLock
;	jq boot_os
