
;@DOES Initialise the standard (8bpp) XLibC palette
;@DESTROYS HL,DE,B,AF
gfx_InitStdPalette:
	ld	hl,ti.mpLcdPalette
	ld	b,l
assert ti.mpLcdPalette and $FF = 0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	ret
