;@DOES Allocates memory in usermem at asm_prgm_size, advancing asm_prgm_size.
;@INPUT void* sys_AllocHeap(size_t len);
;@OUTPUT pointer to memory or 0 if failed.
sys_AllocHeap:
	pop bc,hl
	push hl,bc
	call fs_AllocRam.entryhl
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
	ex hl,de
	pop bc,hl
	push hl,bc
	ld bc,(ti.asm_prgm_size)
	add hl,bc
	ld (ti.asm_prgm_size),bc
	ex hl,de
	ret
