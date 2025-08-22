;@DOES Clears the current display buffer.
;@INPUT A color to fill with
;@DESTROYS HL,DE,BC,F(P/V)
gfx_LcdClear:
	ld	hl,(ti.mpLcdUpbase)
	jq	gfx_BufClear.clear

