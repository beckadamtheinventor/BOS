;@DOES get the physical address of a given sector.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop bc,hl
	push hl,bc
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld bc,fs_filesystem_address
	add hl,bc
	ret
