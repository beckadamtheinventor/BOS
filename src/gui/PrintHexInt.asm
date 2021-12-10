;@DOES print a 24 bit integer in hexadecimal
;@INPUT HL number to display
;@NOTE does not blit the lcd buffer
gui_PrintHexInt:
	push hl
	inc sp
	pop af
	dec sp ; A = HLU
	call gui_PrintHexByte
	ld a,h
	call gui_PrintHexByte
	ld a,l
	jq gui_PrintHexByte

