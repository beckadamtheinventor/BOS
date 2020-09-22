;@DOES draws a sprite to the back buffer
;@INPUT HL pointer to sprite
;@INPUT BC X<<8 + Y
;@DESTROYS HL,DE,BC,AF
gfx_Sprite:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,LCD_BUFFER
	add	hl,de
	ld	b,LCD_WIDTH / 2
	mlt	bc
	add	hl,bc
	add	hl,bc				; draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(ScrapByte),a			; width
	inc	hl
	ld	a,(hl)
	ld (ScrapWord),a            ; height
	inc	hl
.loop:
	ld a,(ScrapByte)
	ld c,a
	push de
	ldir
	ld	hl,ScrapWord
	dec (hl) ; for height
	ld a,(hl)
	ld	de,LCD_WIDTH
	pop hl
	add hl,de
	ex hl,de
	or a,a
	jr	nz,.loop
	ret

