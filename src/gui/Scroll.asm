
gui_Scroll:
	ld de,LCD_BUFFER
	ld hl,LCD_BUFFER + 320*9
	ld bc,320 * (240 - 9)
	ldir
	ld hl,LCD_BUFFER + 320 * (240 - 9)
	ld de,LCD_BUFFER + 320 * (240 - 9) + 1
	ld a,(lcd_text_bg)
	ld (hl),a
	ld bc,320 * 9
	ldir
	jq gfx_BlitBuffer
