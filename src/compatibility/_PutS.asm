;@DOES Print a string to the current cursor position and blit the buffer when finished.
;@INPUT HL = string
_PutS:
	push hl
	or a,a
	sbc hl,hl
	ld a,(console_col)
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	call sys_AddHLAndA
	ld a,(console_line)
	ld c,a
	add a,a
	add a,a
	add a,a
	add a,c
	call gfx_SetTextXY
	pop hl
.loop:
	ld a,(hl)
	inc hl
	or a,a
	jr z,.gfx_BlitBuffer
	push hl
	call gfx_PrintChar
	pop hl
	jr .loop
.gfx_BlitBuffer:
	push hl,af
	call gfx_BlitBuffer
	pop af,hl
	ret
