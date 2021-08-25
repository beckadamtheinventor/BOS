
;@DOES Reset the current font to the default built-in font
;@DESTROYS BC
gfx_SetDefaultFont:
	ld bc,data_font_data
	ld (font_data),bc
	ld bc,data_font_spacing
	ld (font_spacing),bc
	ret
