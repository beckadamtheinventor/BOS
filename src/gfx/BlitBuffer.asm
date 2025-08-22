;@DOES copies the current back buffer to the current display buffer.
;@DESTROYS HL,DE,BC
gfx_BlitBuffer:
	ld	hl,(cur_lcd_buffer)
	ld	de,(ti.mpLcdUpbase)
.copy:
	ld	bc,LCD_WIDTH * LCD_HEIGHT
	ldir
	ret

