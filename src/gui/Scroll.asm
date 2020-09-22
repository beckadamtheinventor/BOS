
gui_Scroll:
	ld de,LCD_BUFFER
	ld hl,LCD_BUFFER + 320*9
	ld bc,320 * (240 - 9)
	push bc
	ldir
	ld hl,$FF0000
	ld de,LCD_BUFFER + 320 * (240 - 9)
	pop bc
	ldir
	jp gfx_BlitBuffer
