
;@DOES Set the text cursor position
;@INPUT void _SetCursorPos(uint8_t row, uint8_t col);
_SetCursorPos:
	pop bc,de,hl
	push hl,de,bc
	ld a,l
	ld (currow),a
	ld a,e
	ld (curcol),a
	ret

