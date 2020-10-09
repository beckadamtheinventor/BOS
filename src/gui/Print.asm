
gui_Print:
	ld a,(console_line)
	push hl
	ld c,a
;multiply line by 9 to get Y position
	add a,a
	add a,a
	add a,a
	add a,c
	or a,a
	sbc hl,hl
	call gfx_SetTextXY
	pop hl
.print:
	call gfx_PrintString
	jq c,.controlcode
	ret

.scroll:
	push hl
	call gui_Scroll
	pop hl
	jq .

.controlcode:
	or a,a
	jr z,.nextline
	cp a,$0A ;LF
	jq z,.nextline
	cp a,$09 ;TAB
	jq nz,.print
.tab:
	ld a,(lcd_x)
	and a,$F0
	add a,$10
	ld (lcd_x),a
	jq .print
.nextline:
	ld a,(console_line)
	cp a,25
	jq nc,.scroll
	inc a
	ld (console_line),a
	push hl
	call gfx_BlitBuffer
	pop hl
	jq .
