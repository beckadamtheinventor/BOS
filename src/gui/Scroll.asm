
gui_Scroll:
	ld de,LCD_BUFFER
	ld hl,LCD_BUFFER + 320*9
	ld bc,320 * (240 - 9)
	ldir
	ld hl,LCD_BUFFER + 320 * (240 - 9)
	ld a,(lcd_bg_color)
	ld bc,320 * 9
	call gfx_BufClear.clearbc
	jq gfx_BlitBuffer
