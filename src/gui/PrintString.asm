;@DOES print a string to the current draw buffer, advancing curcol
;@INPUT HL pointer to string
;@OUTPUT HL pointer to character following the null terminator.
;@DESTROYS HL,DE,BC,AF
gui_PrintString:
.loop:
	ld a,(hl) ; character to print
	inc hl
	or a,a
	ret	z
	call gui_PrintChar ; saves hl
	jr .loop

