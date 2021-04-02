

;@DOES clear the screen and display a string
;@INPUT hl = string
;@NOTE resets the text colors to white on black
gui_DrawConsoleWindow:
	push hl
	ld a,$FF
	ld (lcd_text_fg),a
	xor a,a
	ld (lcd_text_bg),a
	ld (console_line),a
	call gfx_BufClear
	pop hl
	jp gui_PrintLine
