;@DOES get the sector a given address lies within
;@INPUT int fs_GetSector(void *address);
fs_GetSector:
	pop bc,hl
	push hl,bc
	ld a,(filesystem_driver)
	or a,a
	jq nz,.otherfs
	ld de,-fs_filesystem_root_address
	ld bc,9
.div:
	add hl,de
	jp ti._idivu
.otherfs:
	ld de,-fs_filesystem_root_address
	ld bc,8 ;256
	cp a,1 ;alternative bosfs with 256b clusters
	jq z,.div
	
	ret


