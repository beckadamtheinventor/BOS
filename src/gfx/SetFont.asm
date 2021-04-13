
;@DOES set the current font
;@INPUT void *gfx_SetFont(void *data)
;@OUTPUT HL = old font data
;@NOTE data structure: uint8_t num_bitmaps, uint8_t spacing[], uint8_t data[]
gfx_SetFont:
	ld de,(font_spacing)
	pop bc,hl
	push hl,bc
	ld bc,0
	ld c,(hl)
	inc bc
	inc hl
	ld (font_spacing),hl
	add hl,bc
	ld (font_data),hl
	ex hl,de
	dec hl
	ret
