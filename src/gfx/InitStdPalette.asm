
;@DOES Initialise the standard (8bpp) XLibC palette
;@DESTROYS DE,BC,AF
gfx_InitStdPalette:
; setup common items
	ld	a,$27
	ld	(LCD_CTRL),a
	ld	de,LCD_PAL  ; address of mmio palette
	ld	b,e         ; b = 0
.loop:
	ld	a,b
	rrca
	xor	a,b
	and	a,224
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rla
	rla
	rla
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,.loop		; loop for 256 times to fill palette
	ret
