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
	; ld de,(ti.asm_prgm_size)
	; sbc hl,de
	pop de,hl
	; jr c,.insert_mem
.insert_mem:
	push de,hl
	; memmove(arg_de+arg_hl, arg_de, end_of_usermem - arg_de+arg_hl)
	add hl,de ; arg_de+arg_hl
	push hl,hl
	pop bc
	ld hl,end_of_usermem
	or a,a
	sbc hl,bc ; end_of_usermem - arg_de+arg_hl
	ex (sp),hl
	push de,hl ; arg_de, arg_de+arg_hl
	call ti._memmove
	pop hl,de,bc
	pop hl ; bytes to insert
	push de ; destination passed to memmove
	call _UpdateVAT
	pop hl,de ; pop destination passed to memmove, then the address inserted to
	ld iy,ti.flags
	ret
; .not_usermem:
	
.pop2_fail:
	scf
	sbc hl,hl
.pop2_exit:
	pop bc,bc
	ret
