

;@DOES clear the screen and display a string
;@INPUT hl = string
gui_DrawConsoleWindow:
	push hl
	xor a,a
	ld (currow),a
	ld a,(lcd_text_bg)
	call gfx_BufClear
	pop hl
	jp gui_PrintLine
