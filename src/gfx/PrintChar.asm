;@DOES Print a character to the current draw buffer.
;@INPUT A Character to draw
;@OUTPUT DE = Pointer to draw location
;@DESTROYS BC
gfx_PrintChar:
character_width := 8
character_height := 8
	push	hl
	push	af ; character

; copy the ram code
	ld	hl,.ram_code
	ld	de,.ram_code_location
	ld	bc,.ram_code.len
	ldir
	ld	c,a

; set up the text colors in the copied code
	ld	a,(text_flags)
	bit	textflag_transparent_bg, a
	jr	z,.non_transparent_bg
	xor	a,a
	ld	(.ram_code_bg - 1),a ; change the opcode byte to a nop to skip writing the background color byte
	jr .draw_char
.non_transparent_bg:
	bit	textflag_transparent_fg, a
	jr	nz,.transparent_fg_color
	ld	a,(lcd_text_fg)
	ld	(.ram_code_fg),a
	jr	.set_bg_color
.transparent_fg_color:
	xor	a,a
	ld	(.ram_code_fg - 1),a ; change the opcode byte to a nop to skip writing the foreground color byte
.set_bg_color:
	ld	a,(lcd_text_bg)
	ld	(.ram_code_bg),a

	ld hl,(lcd_x)
	ld de,(lcd_y)
	call gfx_Compute
	push hl
	ex hl,de

; input de = pointer to draw location on screen
; input c = character to draw
.draw_char:
	ld a,c
	sbc	hl,hl
	ld	l,a
	add	hl,hl ; x2
	add	hl,hl ; x4
	add	hl,hl ; x8
	ld	bc,(font_data)
	add	hl,bc				; hl -> character bitmap
	ld	a,character_height
.vert_loop:
	ld c,a
	ld	a,(hl)
	inc	hl
	; hl = pointer to next byte of the character bitmap
	ld	b,character_width
	ex	hl,de
	jp .ram_code_location
.ram_code_return:
	ld	a,c
	ld	bc,LCD_WIDTH - character_width
	add	hl,bc
	ex	hl,de
	dec	a
	jr	nz,.vert_loop

	pop de ; de = pointer to original draw location
	pop	af ; a = character
	ld bc,(font_spacing)
	or a,a
	sbc hl,hl
	ld l,a
	add hl,bc
	ld a,(hl) ; amount to step for this character
	sbc hl,hl
	ld l,a
	ld bc,(lcd_x)
	add hl,bc
	ld (lcd_x),hl ; advance lcd_x
	pop	hl
	ret

virtual at gfx_routine_temp
	.ram_code_location:
	.horiz_loop:
		rlca
		jr	nc,.bg
		ld	(hl),0
	.ram_code_fg := $-1
		jr	.nextpx
	.bg:
		ld	(hl),0
	.ram_code_bg := $-1
	.nextpx:
		inc	hl
		djnz	.horiz_loop
		jp	.ram_code_return
	.ram_code.len := $ - .ram_code_location
	load .ram_code_data: $ - $$ from $$
end virtual
.ram_code:
	db .ram_code_data
assert .ram_code.len <= 16 ; assure that this fits in the allocated memory
