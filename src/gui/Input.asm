;@DOES Get string input from the user.
;@INPUT uint8_t gui_Input(char *buffer, int max_len);
;@OUTPUT 0 if user exit, 1 if user enter, 9|12 if user presses down|up arrow key
;@DESTROYS HL,DE,BC,AF
gui_Input:
	ld hl,-12
	call ti._frameset
	xor a,a
	sbc hl,hl
	ld (ix-3),hl ; input current length
	ld (ix-11),hl ; cursor position
	ld hl,(ix+6)
	ld (hl),a
	push hl
	pop de
	inc de
	ld bc,(ix+9)
	dec bc
	ldir
.enter_no_clear_buffer:
	xor a,a
	ld (ix-12),a ; character for character wheel
	inc a
	ld (ix-4),a
	ld a,(currow)
	ld (ix-5),a
	jr .entry
.draw:
	ld a,(ix-5)
	ld (currow),a
.entry:
	call .clear_line
	xor a,a
	ld (curcol),a
	ld hl,(ix+6)
	call ._printlines
	call gfx_SwapTextColors
	ld bc,0
	ld hl,.overtypes
	ld c,(ix-4)
	add hl,bc
	ld bc,(lcd_x)
	ld (ix-8),bc
	ld a,(hl)
	call gui_PrintChar
	ld hl,(ix-11)
	ld bc,(ix-3)
	or a,a
	sbc hl,bc
	add hl,bc
	call .draw_underline
	call gfx_SwapTextColors
	call gfx_BlitBuffer
.keys:
	call sys_WaitKeyCycle
	cp a,5
	jq c,.arrow_key
	cp a,56
	jq z,.delete
	cp a,15
	jq z,.exit
	cp a,54
	jq z,.nextmap
	cp a,ti.skGraph
	jq z,.paste
	cp a,ti.skTrace
	jq z,.copy
	cp a,ti.skMode
	jq z,.char_wheel
	cp a,9
	jq z,.enter
	jq c,.keys
	cp a,48
	jq z,.prevmap
	jq nc,.keys
	ld bc,0
	ld c,(ix-4)
	ld hl,.keymaps
	add hl,bc
	add hl,bc
	add hl,bc
	ld hl,(hl)
	sub a,10
	ld c,a
	add hl,bc
	ld a,(hl)
.inserta:
	or a,a
	jq z,.keys ;don't insert a character if the character is null
	ld (ix-12),a ; save last input character for character wheel
	ld hl,(ix-3)
	ld bc,(ix+9)
	inc hl
	or a,a
	sbc hl,bc
	jq nc,.keys ;don't insert a character if there's no room left in the buffer
	ld hl,(ix+6)
	ld bc,(ix-11)
	add hl,bc
	ld (hl),a
	inc bc
	ld (ix-11),bc
	ld bc,(ix-3)
	inc bc
	ld (ix-3),bc
	jq .draw
.delete:
	ld bc,(ix-11)
	ld a,(ix-3)
	or a,b
	or a,c
	jq z,.draw
	ld hl,(ix+6)
	ld bc,(ix-3)
	dec bc
	add hl,bc
	ld (hl),0
	ld (ix-3),bc
	ld (ix-11),bc
	jq .draw
.arrow_key:
	cp a,3
	jq z,.cursor_right
	cp a,2
	jq z,.cursor_left
	add a,8
	jq .return
.enter:
	ld a,(ix-4)
	cp a,3
	jq nz,.actuallyenter
	ld a,$A ;insert a newline char if pressing enter on 'x' overtype
	jq .inserta
.actuallyenter:
	ld a,1
	jr .return
.exit:
	xor a,a
	ld hl,(ix+6)
	ld (hl),a
.return:
	ld hl,(ix+6)
	ld sp,ix
	pop ix
	push af
	call gui_NewLine
	pop af
	ret
.cursor_left:
	ld hl,(ix-11)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.keys ;do nothing if we're already at the start of the string
	dec hl
	ld (ix-11),hl
	jq .draw
.cursor_right:
	ld hl,(ix-11)
	ld bc,(ix-3)
	or a,a
	sbc hl,bc
	jq nc,.keys ;do nothing if we're already at the eol
	add hl,bc
	inc hl
	ld (ix-11),hl
	jq .draw
.clear_line:
	ld a,(currow)
	ld hl,LCD_BUFFER
	ld c,a
	add a,a
	add a,a
	add a,a
	add a,c
	ld c,a
	ld b,160
	mlt bc
	add hl,bc
	add hl,bc
	push hl
	pop de
	inc de
	ld a,(lcd_bg_color)
	ld (hl),a
	ld bc,320*9 - 1
	ldir
	ret
.prevmap:
	ld a,(ix-4)
	or a,a
	jr nz,.decmap
	ld a,4
.decmap:
	dec a
.setmap:
	ld (ix-4),a
	jq .draw
.nextmap:
	ld a,(ix-4)
	inc a
	cp a,4
	jr c,.setmap
	xor a,a
	jr .setmap

.draw_underline:
	push af
	; compute row offset from input current length
	ld hl,(ix-11)
	ld bc,40
	call ti._idvrmu
; hl = remainder, de = result
	push hl
	ld a,(currow)
	add a,e
	inc a
	ld e,a
	add a,a
	add a,a
	add a,a
	add a,e
	ld e,a
	sbc hl,hl
	push de
	call gfx_Compute
	push hl
	pop de
	inc de
	ld a,(lcd_text_bg)
	ld (hl),a
	ld bc,319
	ldir
	pop de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	call gfx_Compute
	pop af
	ld a,(lcd_text_fg)
	jr c,.draw_horiz_8_a_hl
	ld a,(lcd_text_bg)
.draw_horiz_8_a_hl:
	ld b,8
.draw_underline.horiz_loop:
	ld (hl),a
	inc hl
	djnz .draw_underline.horiz_loop
	ret

._printlines_scroll:
	push hl
	call gui_Scroll
	pop hl
._printlines:
	call gui_PrintString
	ret nc
.controlcode:
	or a,a
	jr z,.nextline
	cp a,$0A ;LF
	jq z,.nextline
	cp a,$09 ;TAB
	jq nz,._printlines
.tab:
	ld a,(curcol)
	add a,3
	ld (curcol),a
	jq ._printlines
.nextline:
	xor a,a
	ld (curcol),a
	ld a,(currow)
	cp a,25
	jq nc,._printlines_scroll
	inc a
	ld (currow),a
	push hl
	call gfx_BlitBuffer
	call .clear_line
	pop hl
	jq ._printlines

.paste:
	ld hl,(ix+9)
	ld bc,(ix-11)
	or a,a
	sbc hl,bc
	jq z,.keys ; no room in buffer
	push hl
	ld hl,(ix+6) ; buffer pointer
	add hl,bc ; buffer write pointer
	ex hl,de
	pop bc ; characters remaining in buffer
	ld hl,(copy_buffer)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.keys ; nothing to paste
	push de,bc,hl,de
	call ti._strncpy
	pop bc,bc,bc
	call ti._strlen
	ex hl,de
	ld hl,(ix-11)
	add hl,de
	ld (ix-11),hl ; advance cursor
	ld hl,(ix-3)
	add hl,de
	ld (ix-3),hl ; advance buffer length
	jq .draw

.copy:
	ld hl,(ix+6)
	push hl
	call ti._strlen
	inc hl
	push hl
	call sys_Malloc.entryhl
	pop bc
	ex hl,de
	pop hl
	jq c,.keys
	push de
	ldir
	ld hl,(copy_buffer)
	call sys_Free.entryhl
	pop hl
	ld (copy_buffer),hl
	jq .draw

; character selection by arrow keys
.char_wheel:
assert currow+1 = curcol
; save currow/curcol
	ld bc,(currow)
	push bc
; draw underline and overline
	ld hl,(ix-11)
	ld bc,40
	call ti._idvrmu
	ld a,l
	ld (curcol),a
	push hl
	add hl,hl
	add hl,hl
	add hl,hl
	pop bc
	add hl,bc
	push hl ; hl = col*9 (character column -> pixel column)
	ld a,(currow)
	add a,e
	ld (currow),a
	ld e,a
	add a,a
	add a,a
	add a,a
	add a,e
	add a,9
	ld e,a ; e = row*9+9 (character row -> pixel row)
	pop hl
	call gfx_Compute
	; draw overline
	ld a,(lcd_text_fg)
	call .draw_horiz_8_a_hl
	; ld de,320*10-8 ; seek 10 rows down, 8 columns back
	; add hl,de
	; call .draw_horiz_8_a_hl

.char_wheel_loop:
	ld a,(ix-12)
	call gui_PrintChar
	call gfx_BlitBuffer
	ld a,(curcol)
	dec a
	ld (curcol),a
.char_wheel_key_loop:
	call sys_WaitKeyCycle
	cp a,ti.skUp
	jr z,.char_wheel_next_char
	cp a,ti.skDown
	jr z,.char_wheel_prev_char
	cp a,ti.skRight
	jr z,.char_wheel_next_char_8
	cp a,ti.skLeft
	jr z,.char_wheel_prev_char_8
	cp a,ti.skClear
	jq z,.draw
	cp a,ti.skEnter
	jr nz,.char_wheel_key_loop
	ld a,(ix-12)
	jr .char_wheel_return_nonzero
.char_wheel_return_nonzero:
	; restore currow/curcol
	pop bc
	ld e,a
	ld a,c
	ld (currow),a
	ld a,b
	ld (curcol),a
	ld a,e
	jq .inserta

.char_wheel_next_char:
	ld a,(ix-12)
	inc a
	jr .char_wheel_set_char

.char_wheel_next_char_8:
	ld a,(ix-12)
	add a,8
	jr .char_wheel_set_char

.char_wheel_prev_char:
	ld a,(ix-12)
	dec a
	jr .char_wheel_set_char

.char_wheel_prev_char_8:
	ld a,(ix-12)
	sub a,8
.char_wheel_set_char:
	dec a
	and a,$7F
	inc a
	ld (ix-12),a
	jq .char_wheel_loop

.keymaps:
	dl .keymap_A,.keymap_a,.keymap_1,.keymap_x
.keymap_len := 38
.keymap_A:
	db '"',"WRMH",0,0,"?!VQLG",0,0,":ZUPKFC",0," YTOJEB",0,0,"XSNIDA"
.keymap_a:
	db '"',"wrmh",0,0,"?!vqlg",0,0,":zupkfc",0," ytojeb",0,0,"xsnida"
.keymap_1:
	db "+-*/^",0,0,";369)$@",0,".258(&~",0,"0147,][",0,0,"'<=>}{"
.keymap_x:
	db "'][",$5C,$7F,0,0,";369}## =258{&~ _147,][  '<=>}{"
.overtypes:
	db "Aa1x"
