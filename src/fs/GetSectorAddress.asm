;@DOES get the physical address of a given sector.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop hl,de
	push de,hl
	ex.s hl,de
	ld a,(filesystem_driver)
	or a,a
	jq nz,.otherfs
	ld de,fs_filesystem_root_address
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	add hl,de
	ret
.otherfs:
	ld de,fs_filesystem_root_address
	ld b,8 ;256
	cp a,1 ;alternative bosfs with 256b clusters
	jq z,.mult_loop
	
	ret

