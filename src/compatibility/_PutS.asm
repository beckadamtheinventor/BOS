;@DOES Print a string to the current cursor position and blit the buffer when finished.
;@INPUT HL = string
_PutS:
	push hl
	ld a,(console_line)
	ld c,a
	add a,a
	add a,a
	add a,a
	add a,c
	or a,a
	sbc hl,hl
	call gfx_SetTextXY
	pop hl
.loop:
	ld a,(hl)
	or a,a
	jp z,gfx_BlitBuffer
	inc hl
	push hl
	call gfx_PrintChar
	pop hl
	jr .loop
