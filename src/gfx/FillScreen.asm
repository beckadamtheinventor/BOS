;@DOES clears the current buffer
;@INPUT A color to fill with
;@DESTROYS HL,DE,BC,F(P/V)
gfx_BufClear:
	ld	hl,(cur_lcd_buffer)
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
.clear:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

