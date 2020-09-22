;@DOES draws a filled rectangle to the back buffer
;@INPUT BC rectangle width
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT A rectangle height
;@DESTROYS HL,DE,BC,AF
gfx_FillRectangle:
	ld	d,LCD_WIDTH / 2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
.computed:
	ld	(ScrapWord),bc
	ld  hl,LCD_BUFFER			; de -> place to begin drawing
.loop:
	ld	(ScrapByte),a
	ld	bc,(ScrapWord)
	ld	a,(color_primary)		; always just fill with the primary color
	ld (de),a					; check if we only need to draw 1 pixel
	inc de
	dec bc
	jp	po,.skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
.skip:
	ld	de,LCD_WIDTH			; move to next line
	add hl,de
	ld a,(ScrapByte)
	dec a
	jr	nz,.loop
	ret

