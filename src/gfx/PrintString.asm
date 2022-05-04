;@DOES print a string to the current lcd buffer
;@INPUT HL pointer to string
;@OUTPUT HL pointer to character after the last one printed
;@OUTPUT Cf set if a control code is encountered or if the text would overflow the line.
;@OUTPUT A = control code if a control code is encountered. (Cf will be set)
;@DESTROYS All
;@NOTE If you need a routine callable from C, this is not the one you'll want to use.
gfx_PrintString:
	ld	a,(lcd_y)
	cp	a,TEXT_MAX_ROW
	ret nc
.loop:
	ld	a,(hl)
	inc hl
	cp a,$20
	ret c
	cp a,$80
	ccf
	ret c
	call	gfx_PrintChar			; saves de, hl
	ex	hl,de
	ld	bc,LCD_WIDTH - 8
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,bc
	ex	hl,de
	jr	c,.loop
	xor a,a   ; return a=0 to inform the caller we returned without a control code, but set the carry flag so the caller knows that we hit the end of the line (on screen)
	scf
	ret

