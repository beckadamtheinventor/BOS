;@DOES clears VRAM with null bytes
;@DESTROYS HL,DE,BC,AF
gfx_ZeroVRAM:
	xor	a,a
	ld	hl,LCD_VRAM
	ld	bc,ti.lcdWidth*ti.lcdHeight*2 - 1
	jq	gfx_BufClear.clearbc

