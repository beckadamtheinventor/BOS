;@DOES Write the currently cached sector back to flash sector A
sys_WriteSectorCache:
	pop bc,hl
	push hl,bc
	ld a,l
.entry:
	push af
	call sys_FlashUnlock
	call sys_EraseFlashSector
	dec sp
	pop de ; DEu = A
	inc sp
	ld bc,$010000
	ld e,c
	ld d,c
	ld hl,LCD_VRAM
	call sys_WriteFlash
	ld de,(saved_LcdUpbase)
	ld hl,LCD_VRAM
	or a,a
	sbc hl,de
	jq nz,sys_FlashLock
	ld hl,LCD_BUFFER
	ld bc,LCD_WIDTH*LCD_HEIGHT
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
.dont_writeback_vram:
	jq sys_FlashLock
