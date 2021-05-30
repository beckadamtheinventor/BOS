;@DOES print a string to the current lcd buffer at a given XY position
;@INPUT void gfx_PrintStringXY(const char *str, int x, uint8_t y);
;@DESTROYS All
gfx_PrintStringXY:
	call ti._frameset0
	ld hl,(ix+9)
	ld a,(ix+12)
	ld (lcd_x),hl
	ld (lcd_y),a
	ld	de,LCD_WIDTH - 10
	ld hl,(ix+6)
	pop ix
.loop:
	ld	a,(hl)
	inc hl
	or	a,a
	ret	z
	cp a,$20
	ret c
	cp a,$80
	ccf
	ret c
	call	gfx_PrintChar			; saves de, hl
	push	hl
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,de
	jr	c,.next
	xor a,a   ; return a=0, but set the carry flag so the caller knows we hit the end of the line
	scf
	pop hl
	ret
.next:
	pop hl
	jr	.loop

