;@DOES Write the currently cached sector back to flash sector A
sys_WriteSectorCache:
	call sys_FlashUnlock
	push af
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
	jr nz,.dont_writeback_vram
	ex hl,de
	ld hl,LCD_BUFFER
	ld bc,LCD_WIDTH*LCD_HEIGHT
	ldir
.dont_writeback_vram:
	jq sys_FlashLock
