
gui_NewLine:
	xor a,a
	ld (curcol),a
	sbc hl,hl
	ld (lcd_x),hl
	ld a,(console_line)
	cp a,25
	jq nc,.scroll
	inc a
	ld (console_line),a
	jp gfx_BlitBuffer
.scroll:
	call gui_Scroll
	jp gfx_BlitBuffer

