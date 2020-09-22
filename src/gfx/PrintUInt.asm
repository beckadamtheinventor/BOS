;@DOES print a number to the back buffer
;@INPUT HL number to display
;@INPUT A characters to use (8-nchars)
;@OUTPUT string stored at gfx_string_temp
;@DESTROYS HL,DE,BC,AF
gfx_PrintUInt:
	dec	a
	ld (ScrapByte),a
	call	sys_HLToString
	ex	de,hl
	ld a,(ScrapByte)
	call	sys_AddHLAndA
	jp	gfx_PrintString

