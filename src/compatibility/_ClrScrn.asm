;@DOES Clear the screen and back buffer
_ClrScrn:
	ld hl,LCD_VRAM
	ld de,LCD_VRAM + 1
	ld bc,LCD_WIDTH*LCD_HEIGHT*2 - 1
	ld (hl),0
	ldir
	ret
