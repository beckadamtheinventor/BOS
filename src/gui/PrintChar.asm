
;@DOES Print a character to the back buffer and advance the text cursor
;@INPUT A = character to print
;@DESTROYS Assume all except HL
gui_PrintChar:
	push hl,af
	ld a,(console_line)
	ld c,a
	add a,a
	add a,a
	add a,a
	add a,c
	ld c,a
	ld hl,(lcd_x)
	push bc,hl
	call gfx_SetTextXY
	pop bc,bc
	pop af
	call gfx_PrintChar
	jq c,.controlcode
.advance:
	ld a,(curcol)
	cp a,40
	jq nc,.advance_new_line
	inc a
	ld (curcol),a
	pop hl
	ret
.advance_new_line:
	xor a,a
	sbc hl,hl
	ld (lcd_x),hl
	ld (curcol),a
	ld a,(console_line)
	cp a,25
	jq nc,.scroll
	inc a
	ld (currow),a
	ld (console_line),a
.done:
	call gfx_BlitBuffer
	pop hl
	ret

.scroll:
	push hl
	call gui_Scroll
	pop hl
	jq .done

.controlcode:
	or a,a
	jr z,.nextline
	cp a,$0A ;LF
	jq z,.nextline
	cp a,$09 ;TAB
	jq nz,.advance
.tab:
	ld hl,(lcd_x)
	ld a,l
	and a,$F0
	ld l,a
	ld bc,$10
	add hl,bc
	ld (lcd_x),hl
	jq .advance
.nextline:
	ld a,(console_line)
	cp a,25
	jq nc,.scroll
	inc a
	ld (console_line),a
	call gfx_BlitBuffer
	jq .advance

