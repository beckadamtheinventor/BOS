;@DOES print a string to the back buffer
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
	ld	de,LCD_WIDTH - 10
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

