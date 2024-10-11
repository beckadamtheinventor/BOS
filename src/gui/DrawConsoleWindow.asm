;@DOES clear the screen and display a string.
;@INPUT hl = string
;@NOTE Sets draw to buffer and display to vram.
gui_DrawConsoleWindow:
	push hl
	xor a,a
	ld (currow),a
	ld (curcol),a
	inc a
	call gfx_SetDraw
	ld a,(lcd_bg_color)
	call gfx_BufClear
	ld hl,LCD_VRAM
	ld (ti.mpLcdUpbase),hl
	pop hl
	jp gui_PrintLine
