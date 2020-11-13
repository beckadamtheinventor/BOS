;@DOES Write a byte to flash, surpassing flash AND logic using the swap sector if needed.
;@INPUT bool sys_WriteFlashByteFull(void *dest, uint8_t byte);
;@OUTPUT true if success, false if failed
sys_WriteFlashByteFull:
	scf
	sbc hl,hl
	call ti._frameset
	ld a,(ix+8)
	cp a,$04
	jq c,.fail
	cp a,$40
	jq nc,.fail
	call sys_FlashUnlock
	ld hl,(ix+6)
	ld a,(ix+9)
	ld c,a
	ld (ix-1),a
	and a,(hl)
	cp a,c
	jq z,.dont_use_swap
	ld de,(ix+6)
	ld bc,1
	push bc
	pea ix-1
	push de
	call sys_WriteFlashFull
	pop bc,bc,bc
	jq .success

.dont_use_swap:
	ld de,(ix+6)
	ld a,(ix+9)
	call sys_WriteFlashA

.success:
	call sys_FlashLock
	db $3E
.fail:
	xor a,a
	ld sp,ix
	pop ix
	ret

