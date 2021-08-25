
gui_Print.scroll:
	push hl
	call gui_Scroll
	pop hl
gui_Print:
.print:
	call gui_PrintString
	ret nc

.controlcode:
	or a,a
	jr z,.nextline
	cp a,$0A ;LF
	jq z,.nextline
	cp a,$09 ;TAB
	jq nz,.print
.tab:
	ld a,(curcol)
	add a,3
	ld (curcol),a
	jq .print
.nextline:
	xor a,a
	ld (curcol),a
	ld a,(currow)
	cp a,25
	jq nc,.scroll
	inc a
	ld (currow),a
	push hl
	call gfx_BlitBuffer
	pop hl
	jq .
