;@DOES Print a character to the current draw buffer and advance the text cursor.
;@INPUT A = character to print
;@DESTROYS BC,DE,AF
gui_PrintChar:
assert curcol = currow+1
	ld de,(currow)
.entry_cold_rowe_chara:
	ld c,a
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
	ld a,c
	push hl ; save original hl
	ld de,(lcd_y) ; e = y coord
	ld hl,(lcd_x) ; hl = x coord
	call gfx_Compute
	push hl ; save draw pointer
	cp a,$20
	jr c,.controlcode
	cp a,$80
	jr nc,.controlcode
	call gfx_PrintChar
.advance:
	ld a,(curcol)
	cp a,COLUMN_COUNT-1
	jr nc,.advance_new_line
	inc a
	ld (curcol),a
.done:
	pop hl ; draw pointer
	ld bc,9 ; blit 9x9 square from back buffer to display buffer
	ld a,c
	call gfx_BlitRectangle.computed
	pop hl ; original hl
	ret

.controlcode:
	or a,a
	jr z,.done_no_blit
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
	add a,TAB_SIZE
	cp a,ROW_COUNT
	jr nc,.nextline
	ld (curcol),a
	jr .done_no_blit
.formfeed:=.carriage_return

.backspace:
	ld a,(curcol)
	or a,a
	jr z,.done_no_blit
	dec a
	ld (curcol),a

.done_no_blit:
	pop de
	pop hl ; restore original hl
	ret

.nextline:
	ld a,(currow)
	cp a,ROW_COUNT-1
	jr c,.nextline_noscroll
	call gui_Scroll
	jr .done_no_blit

.nextline_noscroll:
	inc a
	ld (currow),a
	jr .carriage_return

.advance_new_line:
	xor a,a
	ld (curcol),a
	ld a,(currow)
	inc a
	cp a,ROW_COUNT
	ld (currow),a
	call nc,gui_Scroll
	jr .done_no_blit

