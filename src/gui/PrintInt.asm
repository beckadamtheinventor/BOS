
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
	ld hl,gfx_string_temp+8
	ld de,gfx_string_temp+9
	ld bc,8
	lddr
	ld (hl),'-'
	jq .print
.positive:
	ex hl,de
	call	sys_HLToString
	ex hl,de
.print:
	jp	gui_Print

