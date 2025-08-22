
gui_Scroll:
	ld de,(cur_lcd_buffer)
	ld hl,320*9
	push hl
	add hl,de
	ld bc,320 * (240 - 9)
	ldir
	ex hl,de
	ld a,(lcd_bg_color)
	pop bc
	call gfx_BufClear.clearbc
	jq gfx_BlitBuffer
