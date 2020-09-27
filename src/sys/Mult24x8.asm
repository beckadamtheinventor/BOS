;@DOES Multiply HL (24 bit) by A (8 bit)
;@INPUT HL,A
;@OUTPUT HL
;@DESTROYS AF
sys_Mult24x8:
	rrca
	add hl,hl
	ret z
	jr nc,.
	rlca
	push de
	push hl
	pop de
.loop:
	add hl,de
	dec a
	jr nz,.loop
	pop de
	ret

