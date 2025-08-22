;@DOES draws a filled rectangle to the current draw buffer.
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT BC rectangle width
;@INPUT A rectangle height
;@DESTROYS HL,DE,BC,AF
gfx_FillRectangle:
	ld	d,LCD_WIDTH / 2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
; de -> place to begin drawing
.computed:
.loop:
	push bc
	ld hl,color_primary
	ldi
	jp	po,.skip_copy
	scf
	sbc	hl,hl
	add	hl,de
	push de
	ldir
	pop de
.skip_copy:
	pop bc
	ld	hl,LCD_WIDTH-1
	add hl,de
	ex hl,de
	dec a
	jr	nz,.loop
	ret

