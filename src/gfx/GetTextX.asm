;@DOES Return the current lcd X position
;@INPUT int gfx_GetTextX(void);
gfx_GetTextX:
	ld hl,(lcd_x)
	ret
