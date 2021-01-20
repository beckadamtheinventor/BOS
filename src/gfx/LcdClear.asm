;@DOES clears the lcd
;@INPUT A color to fill with
;@DESTROYS HL,DE,BC,F(P/V)
gfx_LcdClear:
	ld	hl,LCD_VRAM
	ld	bc,LCD_WIDTH * LCD_HEIGHT - 1
	jq	gfx_BufClear.clear

