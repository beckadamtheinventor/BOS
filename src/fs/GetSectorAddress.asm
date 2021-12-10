;@DOES get the physical address of a given sector.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop de,hl
	push hl,de
.entry:
	ex hl,de
	ex.s hl,de
	ld b,9
	bit 7,h
	jq nz,.ram_sector
	ld de,fs_filesystem_root_address
.mult_loop:
	add hl,hl
	djnz .mult_loop
	add hl,de
	ret
.ram_sector:
	res 7,h
	ld de,ti.userMem
	add hl,hl
	add hl,hl
	add hl,de
	ret
