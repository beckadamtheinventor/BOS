;@DOES Set the current draw buffer
;@INPUT A buffer number 0 or 1
;@DESTROYS HL
gfx_SetDraw:
	ld hl,LCD_VRAM
	or a,a
	jr z,.set
	ld hl,LCD_BUFFER
.set:
	ld (lcd_buffer),hl
	ret

