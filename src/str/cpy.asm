;@DOES copy null-terminated string
;@INPUT HL pointer to null-terminated string
;@INPUT DE pointer to destination
;@OUTPUT HL pointer to null-terminated string
;@OUTPUT DE DE+HL+strlen(HL)
;@OUTPUT BC BC-strlen(HL)
;@DESTROYS AF
strcpy:
	xor a,a
	ld bc,0
.loop:
	cp a,(hl)
	ldi
	jr nz,.loop
	ex hl,de
	add hl,bc
	ret

