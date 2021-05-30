;@DOES Return the current lcd Y position
;@INPUT int gfx_GetTextY(void);
gfx_GetTextY:
	ld a,(lcd_y)
	or a,a
	sbc hl,hl
	ld l,a
	ret
