;@DOES HL+=A
;@INPUT HL number
;@INPUT A increment
;@OUTPUT HL number+increment
;@DESTROYS AF
sys_AddHLAndA:
	push bc
	ld	bc,0
	ld	c,a
	add	hl,bc
	pop bc
	ret

