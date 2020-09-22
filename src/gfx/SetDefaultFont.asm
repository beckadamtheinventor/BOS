
gfx_SetDefaultFont:
	ld hl,data_font_data
	ld (font_data),hl
	ld hl,data_font_spacing
	ld (font_spacing),hl
	ret
