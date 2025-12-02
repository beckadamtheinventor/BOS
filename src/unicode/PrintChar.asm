;@DOES Print a Unicode character to the current draw buffer and advance the text cursor.
;@INPUT HL = codepoint to print
;@OUTPUT Cf set if invalid/unknown Unicode character or if codepoint is not defined in the font.
;@DESTROYS BC,DE,AF
unicode_PrintChar:
.character_width := 16
.character_height := 16
	call unicode_GetCharacterBitmap.entryhl
	ret c
	push hl
	call gfx_PrintChar.common
	ex de,hl
	ld a,$C9
	ld (gfx_PrintChar.ram_code_return_loc),a
	ex de,hl
	pop de
	; hl = pointer to screen
	; de = pointer to character bitmap
	push hl
	ld	a,.character_height
.vert_loop:
	ld c,a
	; de = pointer to next byte of the character bitmap
	ld	a,(de)
	inc	de
	ld	b,8
	call gfx_PrintChar.ram_code_location
	ld	a,(de)
	inc	de
	ld	b,8
	call gfx_PrintChar.ram_code_location
	ld	a,c
	ld	bc,LCD_WIDTH - .character_width
	add	hl,bc
	dec	a
	jr	nz,.vert_loop
	pop de ; de = pointer to original draw location
	ld hl,.character_width
	ld bc,(lcd_x)
	add hl,bc
	ld (lcd_x),hl ; advance lcd_x
	ret

