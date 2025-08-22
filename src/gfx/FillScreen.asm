;@DOES Clears the current draw buffer.
;@INPUT A color to fill with
;@DESTROYS HL,DE,BC,F(P/V)
gfx_FillScreen:
	ld	hl,(cur_lcd_buffer)
	jq	gfx_BufClear.clear
