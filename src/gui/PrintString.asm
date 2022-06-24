;@DOES print a string to the current lcd buffer, advancing curcol
;@INPUT HL pointer to string
;@OUTPUT HL pointer to character after the last one printed
;@OUTPUT Cf set if a control code is encountered or if the text would overflow the line.
;@OUTPUT A = control code if a control code is encountered. (Cf will be set)
;@DESTROYS All
;@NOTE If you need a routine callable from C, this is not the one you'll want to use.
gui_PrintString:
	push hl
	ld hl,(curcol)
	ld h,9
	mlt hl
	ld (lcd_x),hl
	ld a,(currow)
	ld c,a
;multiply line by 9 to get Y position
	add a,a
	add a,a
	add a,a
	add a,c
	ld (lcd_y),a
	pop hl
	ld	a,(lcd_y)
	cp	a,TEXT_MAX_ROW
	ret nc
	ld	de,LCD_WIDTH - 10
.loop:
	ld	a,(hl) ; character to print
	inc hl
	or	a,a
	ret	z
	cp a,$20 ; check character < 0x20
	ret c
	cp a,$80 ; check character >= 0x80
	ccf
	ret c
	call	gfx_PrintChar			; saves de, hl
	push	hl
	ld	hl, curcol
	inc	(hl)
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,de
	pop hl
	jr	c,.loop
	xor a,a   ; return a=0, but set the carry flag so the caller knows we hit the end of the line
	scf
	ret

