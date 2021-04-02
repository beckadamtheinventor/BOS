
;@DOES get user input
;@INPUT uint8_t gui_Input(char *buffer, int max_len);
;@OUTPUT 0 if user exit, 1 if user enter, 9/12 if user presses down/up arrow key
;@DESTROYS All
gui_Input:
	ld hl,-8
	call ti._frameset
	xor a,a
	sbc hl,hl
	ld (ix-3),hl
	ld hl,(ix+6)
	ld (hl),a
	inc a
	ld (ix-4),a
	push hl
	pop de
	inc de
	ld bc,(ix+9)
	ldir
.enter_no_clear_buffer:
	ld a,(console_line)
	ld (ix-5),a
	jr .entry
.draw:
	ld a,(ix-5)
	ld (console_line),a
.entry:
	call .clear_line
	ld bc,$FF
	ld (lcd_text_fg),bc
	ld hl,(ix+6)
	call gui_Print
	ld a,7
	ld (lcd_text_fg),a
	ld bc,0
	ld hl,.overtypes
	ld c,(ix-4)
	add hl,bc
	ld bc,(lcd_x)
	ld (ix-8),bc
	ld a,(hl)
	call gfx_PrintChar
	ld a,$FF
	ld (lcd_text_fg),a
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
	ld hl,(ix-3)
	ld bc,(ix+9)
	or a,a
	inc hl
	sbc hl,bc
	jq nc,.keys
	add hl,bc
	ex hl,de
	ld hl,(ix+9)
	sbc hl,de ;cf is set, so we get an extra -1
	push hl
	pop bc
	ld hl,(ix+6)
	add hl,bc
	dec hl
	push hl
	pop de
	inc de
	lddr
	ld hl,(ix+6)
	ld bc,(ix-3)
	add hl,bc
	inc bc
	ld (ix-3),bc
	ld (hl),a
	jq .draw
.delete:
	ld hl,(ix+6)
	ld bc,(ix-3)
	ld a,b
	or a,c
	jq z,.draw
	dec bc
	add hl,bc
	ld (ix-3),bc
	push hl
	ld hl,(ix+9)
	xor a,a
	sbc hl,bc
	push hl
	pop bc
	dec bc
	pop de
	inc hl
	ldir
	ld (de),a
	jq .draw
.arrow_key:
	dec a
	jq z,.return
	dec a
	jq z,.curleft
	dec a
	jq nz,.return
.curright:
	ld de,(ix-3)
	ld hl,(ix+6)
	add hl,de
	ld a,(hl)
	or a,a
	jq z,.keys
	inc de
	ld (ix-3),de
	jq .draw
.curleft:
	ld hl,(ix-3)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.keys
	inc hl
	ld (ix-3),hl
	jq .draw
.enter:
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
.clear_line:
	xor a,a
	ld (curcol),a
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
	ld (hl),0
	ld bc,320*9
	ldir
	ret
.prevmap:
	ld a,(ix-4)
	or a,a
	jr nz,.decmap
	ld a,3
.decmap:
	dec a
.setmap:
	ld (ix-4),a
	jq .draw
.nextmap:
	ld a,(ix-4)
	inc a
	cp a,3
	jr nz,.setmap
	xor a,a
	jr .setmap

.keymaps:
	dl .keymap_A,.keymap_a,.keymap_1,0
.keymap_A:
	db '"',"WRMH  ?!VQLG  :ZUPKFC  YTOJEB  XSNIDA"
.keymap_a:
	db '"',"wrmh  ?!vqlg  :zupkfc  ytojeb  xsnida"
.keymap_1:
	db "+-*/^  ;369)$@ .258(&~ 0147,][  '<=>}{"
.overtypes:
	db "Aa1"
