;@DOES Write a byte to flash, surpassing flash AND logic using the first half of VRAM for swap if needed.
;@INPUT bool sys_WriteFlashByteFullRam(void *dest, uint8_t byte);
;@OUTPUT true if success, false if failed
sys_WriteFlashByteFullRam:
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

	ld hl,(ti.mpLcdUpbase)
	push hl
	ld de,LCD_BUFFER
	or a,a
	sbc hl,de
	add hl,de
	jq z,.no_blit_screen
	ld bc,ti.lcdWidth*ti.lcdHeight ;blit lcd to buffer
	ld (ti.mpLcdUpbase),de
	ldir
.no_blit_screen:
	ld hl,(ix+6)
	ld h,0
	ld l,h
	ld de,ti.vRam
	ld bc,65536
	push bc,hl,de
	ldir
	pop hl,de
	push de,hl
	ld h,d
	ld l,e
	ld (hl),a
	ld a,(ix+8)
	call sys_EraseFlashSector
	pop hl,de,bc
	call sys_WriteFlash
	xor a,a
	call gfx_LcdClear
	pop hl
	ld de,LCD_BUFFER
	or a,a
	sbc hl,de
	add hl,de
	jq z,.success
	ex hl,de
	ld bc,ti.lcdWidth*ti.lcdHeight ;blit buffer back to lcd
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
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

