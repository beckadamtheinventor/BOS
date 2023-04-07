

;@DOES clear the screen and display a string
;@INPUT hl = string
gui_DrawConsoleWindow:
	push hl
	xor a,a
	ld (currow),a
	ld (curcol),a
	ld a,(lcd_bg_color)
	call gfx_BufClear
	pop hl
	jp gui_PrintLine
