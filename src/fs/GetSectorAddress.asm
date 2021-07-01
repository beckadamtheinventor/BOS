;@DOES get the physical address of a given sector.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop hl,de
	push de,hl
	ex.s hl,de
	bit 7,h
	jq nz,.ram_sector
	ld de,fs_filesystem_root_address
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	add hl,de
	ret
.ram_sector:
	res 7,h
	ld b,5
	bit 6,h
	jq nz,.malloc_sector
	ld de,$D00000
	jq .mult_loop
.malloc_sector:
	res 6,h
	ld de,$D30000
	jq .mult_loop
