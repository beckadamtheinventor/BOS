;@DOES Return how many bytes are free in usermem ram.
;@INPUT size_t fs_ChkFreeRam();
fs_ChkFreeRam:
	ld hl,ti.userMem
	ld de,(ti.asm_prgm_size)
	add hl,de
	ex hl,de
	ld hl,end_of_usermem
	or a,a
	sbc hl,de
	ret
