;@DOES print a string to the current draw buffer.
;@INPUT HL pointer to string.
;@OUTPUT HL pointer to character following the null terminator.
;@DESTROYS HL,DE,BC,AF
gfx_PrintString:
.loop:
	ld	a,(hl)
	inc hl
	or a,a
	ret z
	call gfx_PrintChar ; saves hl
	ex	hl,de
	ld	bc,LCD_WIDTH - 8
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,bc
	ex	hl,de
	jr	c,.loop
	ret

