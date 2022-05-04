;@DOES copies the lcd to the back buffer
;@DESTROYS HL,DE,BC
gfx_BlitScreen:
	ld	hl,LCD_VRAM
	ld	de,LCD_BUFFER
	jq	gfx_BlitBuffer.copy

