

;@DOES get pointer to font data
;@OUTPUT hl = current font data
gfx_GetFontPtr:
	ld hl,(font_data)
	ret

