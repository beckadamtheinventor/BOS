;@DOES Set the current draw buffer and display buffer.
;@INPUT A 0: display from LCD_VRAM, draw to LCD_BUFFER. 1: reversed.
;@OUTPUT HL = new display buffer.
;@OUTPUT DE = new draw buffer.
;@DESTROYS HL,DE
gfx_SetDraw:
	ld hl,LCD_VRAM
	ld de,LCD_BUFFER
	or a,a
	jr nz,.setvram
	ex hl,de
.setvram:
	ld (ti.mpLcdUpbase),hl
	ld (cur_lcd_buffer),de
	ret

