;@DOES Input a string of HL bytes from user input
;@INPUT HL input length
;@INPUT DE input buffer
;@OUTPUT HL length of user input
;@DESTROYS HL,DE,BC,AF,IX
sys_InputString:
	ld ix,0
	add ix,sp
	add hl,de
	push hl
	push de
	push de
	xor a,a
	sbc hl,hl
	push hl
	ld hl,(ix+6)
	ld (hl),a
	jr .loop
.nextover:
	ld a,(ix+3)
	inc a
	cp a,3
	jr nz,.setover
	xor a,a
.setover:
	ld (ix+3),a
	jr .loop
.prevover:
	ld a,(ix+3)
	or a,a
	jr nz,.setover2
	ld a,4
.setover2:
	dec a
	ld (ix+3),a
	jr .loop
.char:
	ld de,(ix+12)
	ld hl,(ix+6)
	sbc hl,de
	jr nc,.loop
	or a,a
	sbc hl,hl
	ld l,(ix+3)
	add hl,hl
	add hl,hl
	ex hl,de
	ld hl,data_key_map
	add hl,de
	ld hl,(hl)
	call sys_AddHLAndA
	ld a,(de)
	ld (ix+4),a
	ld a,(hl)
	ld hl,(ix+6)
	ld (hl),a
	inc hl
	xor a,a
	ld (hl),a
	ld (ix+6),hl
.loop:
	ld hl,(lcd_x)
	ld a,(lcd_y)
	push hl
	push af
	ld hl,(ix+9)
	call gfx_PrintString
	ld a,(ix+4)
	call gfx_PrintChar
	pop af
	pop hl
	ld (lcd_x),hl
	ld (lcd_y),a
	call sys_GetKey
	cp a,54
	jr z,.prevover
	cp a,9
	jr z,.done
	jr c,.loop
	cp a,48
	jr z,.nextover
	jr nc,.loop
	cp a,15
	jr nz,.char
	ld hl,(ix+6)
	xor a,a
	ld (hl),a
.done:
	pop bc
	pop bc
	pop de
	pop hl
	ret


