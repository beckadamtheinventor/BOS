;@DOES draws a vertical line
;@INPUT HL line X coordinate
;@INPUT E line Y coordinate
;@INPUT B line length
;@DESTROYS HL,DE,BC,AF
gfx_VertLine:
	dec	b
	call	gfx_Compute			; hl -> drawing location
.computed:
	ld a,(color_primary)
	ld	de,LCD_WIDTH
.loop:
	ld	(hl),a				; loop for height
	add	hl,de
	djnz	.loop
	ret

