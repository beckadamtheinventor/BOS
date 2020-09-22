;@DOES find length of null-terminated string
;@INPUT HL pointer to string
;@OUTPUT BC length of string
;@DESTROYS AF
strlen:
	push hl
	ld bc,0
	xor a,a
.loop:
	cpir
	sbc hl,hl
	sbc hl,bc
	push hl
	pop bc
	pop hl
	ret

