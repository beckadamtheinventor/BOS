;@DOES set the lcd to 8bpp mode
;@DESTROYS HL,DE,BC,AF
gfx_Set8bpp:
	call ti.boot.ClearVRAM
.setup:
	; ld	hl,LCD_VRAM
	; ld	(ti.mpLcdUpbase),hl
	; xor	a,a
	; call	gfx_SetDraw
	ld	a,ti.lcdBpp8 ; operate in 8bpp
	ld	(ti.mpLcdCtrl), a
	jq	gfx_InitStdPalette
