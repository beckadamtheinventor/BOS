;@DOES print a string to the current lcd buffer
;@INPUT HL pointer to string
;@OUTPUT HL pointer to character after the last one printed
;@DESTROYS HL,DE,BC
gfx_PrintString:
	ld	a,(lcd_y)
	cp	a,TEXT_MAX_ROW
	ret nc
.loop:
	ld	a,(hl)
	inc hl
	call	gfx_PrintChar			; saves de, hl
	ex	hl,de
	ld	bc,LCD_WIDTH - 8
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,bc
	ex	hl,de
	jr	c,.loop
	ret

