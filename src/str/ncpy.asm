;@DOES copy null-terminated string, with maximum copy amount
;@INPUT HL pointer to null-terminated string
;@INPUT DE pointer to destination
;@INPUT BC maximum bytes to copy
;@OUTPUT HL pointer to null-terminated string
strncpy:
	xor a,a
.loop:
	cp a,(hl)
	ldi
	ret po
	jr nz,.loop
	ex hl,de
	add hl,bc
	ret


