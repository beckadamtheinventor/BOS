;@DOES draws a sprite to the current buffer at 2x scale
;@INPUT HL pointer to sprite
;@INPUT BC X<<8 + Y
;@DESTROYS HL,DE,BC,AF,fsOP6
gfx_Sprite:
	xor a,a
	ld (fsOP6+1),a
	ld (fsOP6+2),a
	ld	a,(hl) 				; width
	ld	(fsOP6),a
	push	hl
	ld	hl,(fsOP6)
	add	hl,hl
	ld	(fsOP6+3),hl
	ld	de,0
	add	a,a
	ld	e,a
	ld	hl,ti.lcdWidth
	sbc	hl,de
	ld	(fsOP6+6),hl
	pop	hl
	inc	hl
	push	hl
	ld	l,c
	ld	h,ti.lcdWidth / 2
	mlt	hl
	add	hl,hl
	ld	de,(cur_lcd_buffer)
	add	hl,de
	push	hl
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	pop	de
	add	hl,de  				; hl -> sprite data
	ex	de,hl				; a = sprite height
	pop	hl
	ld	b,(hl)
	inc	hl
.loop:
	push	bc
	ld	bc,(fsOP6)
	push	de				; save pointer to current line
.inner_loop:
	ld	a,(hl)
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	hl
	dec	bc
	ld 	a,b
	or	a,c
	jr	nz,.inner_loop
	ex	de,hl
	ld	bc,(fsOP6+6)			; increment amount per line
	add	hl,bc				; hl -> next place to draw
	push	de
	pop	ix				; ix -> location to get from
	ex	de,hl
	ld	bc,(fsOP6+3)				; bc = real size to copy
	pop	hl				; hl -> previous line
	ldir
	ex	de,hl
	ld	bc,(fsOP6+6)
	add	hl,bc
	lea	de,ix
	ex	de,hl
	pop	bc
	djnz	.loop
	ret
