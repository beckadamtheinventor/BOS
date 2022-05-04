;@DOES print a character to the current lcd buffer
;@INPUT A character to draw
;@DESTROYS BC
gfx_PrintChar:
character_width := 8
character_height := 8
	push	hl
	push	af
	push	de

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

.draw_char:
	ld	a,c
	ld	bc,(lcd_x)
	push	bc
	ld	hl,lcd_y
	ld	l,(hl)
	ld	h,LCD_WIDTH / 2
	mlt	hl
	add	hl,hl
	ld	de,(cur_lcd_buffer)
	add	hl,de
	add	hl,bc				; add x value
	push	hl
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,(font_data)
	add	hl,de				; hl -> character bitmap
	pop	de				; de -> correct location on screen
	ld	c,character_height
.vert_loop:
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
	ld	c,a
	dec	c
	jr	nz,.vert_loop
	pop	bc
	pop	de
	pop	af				; character
	ld	hl,character_width
;	ld	hl,(font_spacing)
;	call sys_AddHLAndA
;	ld	a,(hl)				; amount to step per character
;	or	a,a
;	sbc	hl,hl
;	ld	l,a
	add	hl,bc
	ld	(lcd_x),hl
	pop	hl
	ret

virtual at gfx_string_temp
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
