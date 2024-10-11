;@DOES Convert a keycode from sys_GetKey to a text character.
;@INPUT char gui_CharFromCode(uint8_t charset, uint8_t keycode);
;@INPUT charset = character set number to pick from.
;@INPUT keycode = keycode from sys_GetKey.
;@OUTPUT character corresponding to the given charset and keycode; 0 if out of bounds or N/A.
;@DESTROYS HL, DE, AF
gui_CharFromCode:
	ld hl,3
	ld d,l
	add hl,sp
	ld a,(hl) ; a = charset
	and a,d ; currently only 4 valid charsets, so this optimization works for now
	ld e,a
	mlt de ; de = (charset&3)*3
	inc hl
	inc hl
	inc hl
	ld a,(hl) ; a = keycode
	cp a,9
	jr z,.line_feed ; keycode 9 is always a line feed (0xA / 10)
	cp a,gui_Input.keymap_len+10
	jr nc,.return_zero
	ld hl,gui_Input.keymaps
	add hl,de
	ld hl,(hl) ; hl = selected charset
	sub a,10
	ld e,a
	add hl,de
	ld a,(hl)
	ret
.return_zero:
	xor a,a
	ret
.line_feed:
	inc a
	ret
