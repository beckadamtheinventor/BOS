
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
	ex hl,de
	ld a,'-'
	call gui_PrintChar
	jq .print
.positive:
	ex hl,de
;@DOES Print an unsigned integer. Dos not swap buffers.
;@INPUT hl = integer
gui_PrintUInt:
	call	sys_HLToString
	ex hl,de
gui_PrintInt.print:
	jp	gui_PrintString

