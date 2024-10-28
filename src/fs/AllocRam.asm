;@DOES Insert ram following &usermem[asm_prgm_size], returning a pointer to it.
;@INPUT void* fs_AllocRam(size_t len);
fs_AllocRam:
	pop bc,hl
	push hl,bc
.entryhl:
	ex hl,de
	ld hl,ti.userMem
	ld de,(ti.asm_prgm_size)
	add hl,de
	ex hl,de ; hl = len, de = pointer
	add hl,de
	or a,a
	sbc hl,de
	call nz,_InsertMem
	ex hl,de
	ret
