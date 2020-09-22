;@DOES moves the text position 9 rows ahead, and moves the collumn to zero.
;@DESTROYS HL,AF
gfx_NextLine:
	or a,a
	sbc hl,hl
	ld (lcd_x),hl
	ld a,(lcd_y)
	add a,9
	ld (lcd_y),a
	ret

