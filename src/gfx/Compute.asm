;@DOES compute draw location on the back buffer from XY coodinate.
;@INPUT HL X coordinate
;@INPUT E Y coordinate
;@OUTPUT HL pointer to draw location
;@DESTROYS HL,DE
gfx_Compute:
	ld	d,LCD_WIDTH / 2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,LCD_BUFFER
	add	hl,de
	ret

