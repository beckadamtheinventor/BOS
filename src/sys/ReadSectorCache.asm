;@DOES Read flash sector A into the sector cache (VRAM)
sys_ReadSectorCache:
	ld hl,(ti.mpLcdUpbase)
	ld (saved_LcdUpbase),hl
	ld de,LCD_VRAM
	or a,a
	sbc hl,de
	jr nz,.dont_copy_vram
	add hl,de
	ld de,LCD_BUFFER
	ld bc,LCD_WIDTH*LCD_HEIGHT
	ldir
.dont_copy_vram:
	ld (ti.mpLcdUpbase),de
	push af
	dec sp
	pop hl
	inc sp
	ld bc,$010000
	ld l,c
	ld h,c
	ld e,c
	ld d,(LCD_VRAM shr 8) and $FF
	push de
	ldir
	pop hl
	ret
