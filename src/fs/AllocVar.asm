
;@DOES Allocate a TI var in Ram
;@INPUT OP1 = var type, var name
;@INPUT HL = bytes to allocate
;@OUTPUT HL = pointer to length-prefixed data.
;@OUTPUT Cf set and HL = -1 if failed
fs_AllocVar:
	push hl
	inc hl
	inc hl
	push hl
	ld de,(ti.asm_prgm_size)
	ld hl,ti.userMem
	add hl,de
	ex hl,de
	pop hl
	push de
	call _InsertMem
	pop hl
	pop bc
	jr c,.fail
	ld (hl),c
	inc hl
	ld (hl),b
	dec hl
	ret
.fail:
	sbc hl,hl
	ret
