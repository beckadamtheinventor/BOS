;@DOES print a character to the back buffer
;@INPUT A character to draw
;@DESTROYS all except DE
gfx_PrintChar:
character_width := 8
character_height := 8
	push	hl
	push	af
	push	de
	ld	bc,(lcd_x)
	push	bc
	ld	hl,lcd_y
	ld	l,(hl)
	ld	h,LCD_WIDTH / 2
	mlt	hl
	add	hl,hl
	ld	de,LCD_BUFFER
	add	hl,de
	add	hl,bc				; add x value
	push	hl
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,(font_data)
	add	hl,de				; hl -> correct character
	pop	de				; de -> correct location
	ld	a,character_width
.vert_loop:
	ld	c,(hl)
	ld	b,character_height
	ex	de,hl
	push	de
	ld	de,(lcd_text_fg)
.horiz_loop:
	ld	(hl),d
	rlc	c
	jr	nc,.bg
	ld	(hl),e
.bg:
	inc	hl
	djnz	.horiz_loop
	ld	(hl),d
	ld	bc,LCD_WIDTH - character_width
	add	hl,bc
	pop	de
	ex	de,hl
	inc	hl
	dec	a
	jr	nz,.vert_loop
	pop	bc
	pop	de
	pop	af				; character
	ld	hl,(font_spacing)
	call sys_AddHLAndA
	ld	a,(hl)				; amount to step per character
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ld	(lcd_x),hl
	pop	hl
	ret

