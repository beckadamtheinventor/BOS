;@DOES set the lcd to 16bpp mode
;@DESTROYS HL,DE,BC,AF
gfx_Set16bpp:
	ld	hl,LCD_VRAM
	ld	bc,((LCD_WIDTH * LCD_HEIGHT) * 2) - 1
	ld	a,255
	call	sys_MemSet
	ld	a,LCD_16BPP
	ld	(LCD_CTRL),a
	ret

