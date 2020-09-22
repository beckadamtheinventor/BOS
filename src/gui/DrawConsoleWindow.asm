


gui_DrawConsoleWindow:
	push hl
	ld a,$FF
	ld (lcd_text_fg),a
	xor a,a
	ld (console_line),a
	call gfx_BufClear
	pop hl
	jp gui_Print
