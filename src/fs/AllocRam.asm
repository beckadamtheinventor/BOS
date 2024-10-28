;@DOES Insert ram following &usermem[asm_prgm_size], returning a pointer to it.
;@INPUT void* fs_AllocRam(size_t len);
;@OUTPUT pointer to allocated memory, or 0 if not enough space.
fs_AllocRam:
	pop bc,hl
	push hl,bc
.entryhl:
	push hl
	ld hl,ti.userMem
	ld de,(ti.asm_prgm_size)
	add hl,de
	ex hl,de ; de = pointer
	pop hl ; hl = len
	add hl,de
	or a,a
	sbc hl,de
	jr z,.done
	push hl
	add hl,de ; pointer + len
	ld bc,end_of_usermem
	or a,a
	sbc hl,bc ; pointer + len - end_of_usermem
	pop hl
	jr nc,.fail ; fail if pointer + len >= end_of_usermem
	call _InsertMem
.done:
	ex hl,de
	ret
.fail:
	sbc hl,hl
	ret
