;@DOES Set the current draw buffer to a pointer.
;@INPUT HL New draw buffer.
gfx_SetDrawPtr:
	ld (cur_lcd_buffer),hl
	ret

