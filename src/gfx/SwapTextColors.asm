;@DOES Swap lcd_text_fg and lcd_text_fg2
gfx_SwapTextColors:
	ld bc,(lcd_text_fg2)
	ld a,(lcd_text_fg)
	ld (lcd_text_fg2),a
	ld a,c
	ld (lcd_text_fg),a
	ret
