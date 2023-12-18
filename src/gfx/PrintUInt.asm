;@DOES print a number to the current lcd buffer
;@INPUT HL number to display
;@INPUT A number of characters to use
;@OUTPUT string stored at gfx_string_temp
;@DESTROYS HL,DE,BC,AF
gfx_PrintUInt:
	ld c,a
	ld a,8
	sub a,c
	ld (ScrapByte),a
	call	sys_HLToString
	ld hl,gfx_string_temp
	ld a,(ScrapByte)
	call	sys_AddHLAndA
	jp	gfx_PrintString

