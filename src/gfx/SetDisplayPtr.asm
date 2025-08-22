;@DOES Set the current display buffer to a pointer.
;@INPUT HL New display buffer.
gfx_SetDisplayPtr:
	ld (ti.mpLcdUpbase),hl
	ret

