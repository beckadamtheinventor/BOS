;@DOES clears the back buffer
;@INPUT A color to fill with
;@DESTROYS HL,DE,BC,F(P/V)
gfx_BufClear:
	ld	hl,LCD_BUFFER
.clear:
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
.clearbc:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

