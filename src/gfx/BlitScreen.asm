;@DOES copies the current display buffer to the current back buffer.
;@DESTROYS HL,DE,BC
gfx_BlitScreen:
	ld	hl,(ti.mpLcdUpbase)
	ld	de,(cur_lcd_buffer)
	jq	gfx_BlitBuffer.copy

