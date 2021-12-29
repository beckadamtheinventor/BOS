;@DOES insert HL bytes into a ram file at address DE
;@INPUT hl = bytes to insert, de = address to insert at
;@OUTPUT hl = new end of file, de = pointer to the space inserted
_InsertMem:
	push hl,de
	ex hl,de
	ld bc,ti.userMem
	or a,a
	sbc hl,bc
	jr c,.pop2_fail
	ld de,(ti.asm_prgm_size)
	sbc hl,de
	pop de,hl
	jr c,.insert_mem
	
.insert_mem:
	; memmove(arg_de, arg_de+arg_hl, end_of_usermem - arg_de+arg_hl)
	add hl,de ; arg_de+arg_hl
	push hl,hl
	pop bc
	ld hl,end_of_usermem
	or a,a
	sbc hl,bc
	ex (sp),hl ; end_of_usermem - arg_de+arg_hl
	push de,hl ; arg_de+arg_hl, arg_de
	call ti._memmove
	pop hl,de,bc
	push de
	call _UpdateVAT
	pop de
	ld iy,ti.flags
	ret
.not_usermem:
	
.pop2_fail:
	scf
	sbc hl,hl
.pop2_exit:
	pop bc,bc
	ret
