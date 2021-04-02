
;@DOES Print an integer. Does not swap buffers.
;@INPUT hl = integer
gui_PrintInt:
	ex hl,de
	ld hl,$800000
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.positive
	or a,a
	sbc hl,hl
	sbc hl,de
	call	sys_HLToString
	ld hl,gfx_string_temp+9
	ld de,gfx_string_temp+10
	ld bc,9
	lddr
	ld (hl),'-'
	jq .print
.positive:
	ex hl,de
;@DOES Print an unsigned integer. Dos not swap buffers.
;@INPUT hl = integer
gui_PrintUInt:
	call	sys_HLToString
	ld hl,gfx_string_temp
gui_PrintInt.print:
	jp	gui_PrintString

