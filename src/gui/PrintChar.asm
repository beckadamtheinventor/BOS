;@DOES Print a character to the back buffer and advance the text cursor
;@INPUT A = character to print
;@DESTROYS Assume all except HL
gui_PrintChar:
assert curcol = currow+1
	ld de,(currow)
.entry_cold_rowe_chara:
	push af
	ld a,e ; a = currow
	ld e,9
	mlt de ; curcol * 9
	ld (lcd_x),de
	ld e,a ; e = currow
	add a,a ; x2
	add a,a ; x4
	add a,a ; x8
	add a,e ; x9
	ld (lcd_y),a
	pop af
	push hl
	cp a,$20
	jr c,.controlcode
	call gfx_PrintChar
	jr .advance

.controlcode:
	or a,a
	jr z,.nextline
	cp a,$08 ; BS
	jr z,.backspace
	cp a,$0A ; LF
	jr z,.nextline
	cp a,$09 ; TAB
	jr z,.tab
	cp a,$0C ; FF
	jr z,.formfeed
	cp a,$0D ; CR
	; jr z,.carriage_return
	jr nz,.done_no_blit
.carriage_return:
	xor a,a
	ld (curcol),a
	jr .done_no_blit
.tab:
	ld a,(curcol)
	inc a
	inc a
	jr .advance_entry
.formfeed:
	xor a,a
	ld (currow),a
	jr .done_no_blit

.backspace:
	ld a,(curcol)
	or a,a
	jr z,.done_no_blit
	dec a
	ld (curcol),a
	jr .done_no_blit

.nextline:
	ld a,(currow)
	cp a,25
	jq nc,.scroll
	inc a
	ld (currow),a

.advance:
	ld a,(curcol)
.advance_entry:
	cp a,40
	jr nc,.advance_new_line
	inc a
	ld (curcol),a

.done:
	call gfx_BlitBuffer
.done_no_blit:
	pop hl
	ret

.advance_new_line:
	xor a,a
	sbc hl,hl
	ld (lcd_x),hl
	ld (curcol),a
	ld a,(currow)
	cp a,25
	jr nc,.scroll
	inc a
	ld (currow),a
	jr .done

.scroll:
	push hl
	call gui_Scroll
	pop hl
	jr .done

