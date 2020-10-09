

;@DOES set text draw position
;@INPUT hl = X
;@INPUT a = Y
gfx_SetTextXY:
	ld (lcd_x),hl
	ld (lcd_y),a
	ret
