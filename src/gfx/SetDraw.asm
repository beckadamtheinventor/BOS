;@DOES Set the current draw buffer
;@INPUT A buffer number 0 or 1
;@DESTROYS HL
gfx_SetDraw:
	ld hl,LCD_VRAM
	or a,a
	jr z,.setvram
	ld hl,cur_lcd_buffer
.setvram:
	ld (cur_lcd_buffer),hl
	ret

