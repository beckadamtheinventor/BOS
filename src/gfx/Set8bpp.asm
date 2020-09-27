;@DOES set the lcd to 8bpp mode
;@DESTROYS HL,DE,BC,AF
gfx_Set8bpp:
	ld a,$FF
	call	gfx_LcdClear
.setup:
	ld	a,LCD_8BPP
	ld	(LCD_CTRL),a		; operate in 8bpp
	ld	hl,LCD_PAL
	ld	b,0
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

