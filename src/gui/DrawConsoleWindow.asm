;@DOES clear the screen and display a string.
;@INPUT hl = string
;@NOTE Ensures 8bpp mode, sets the draw location to the buffer and display to vram.
gui_DrawConsoleWindow:
	push hl
	call gfx_Ensure8bpp
	xor a,a
	ld (currow),a
	ld (curcol),a
	inc a
	call gfx_SetDraw
	ld a,(lcd_bg_color)
	call gfx_BufClear
	pop hl
	jp gui_PrintLine
