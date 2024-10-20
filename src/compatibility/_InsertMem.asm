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
; copy bytes up
	push de,hl
	; memmove(arg_de+arg_hl, arg_de, top_of_UserMem - arg_de)
	add hl,de ; arg_de+arg_hl
	push hl
	ld hl,(top_of_UserMem)
	or a,a
	sbc hl,de ; end_of_usermem - arg_de
	ex (sp),hl
	push de,hl ; arg_de, arg_de+arg_hl
	call nz,ti._memmove ; only call memmove if amount to move > 0
	pop hl,de,bc
	pop hl ; bytes to insert

; upate top of usermem
	push hl
	ld bc,(top_of_UserMem)
	add hl,bc
	ld (top_of_UserMem),hl
	pop hl

; update VAT
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
