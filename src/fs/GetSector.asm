;@DOES get the sector a given address lies within
;@INPUT int fs_GetSector(void *address);
fs_GetSector:
	pop bc,hl
	push hl,bc
	ld a,(filesystem_driver)
	or a,a
	ld de,-fs_filesystem_root_address
	jq nz,.otherfs
	ld bc,512
.div:
	add hl,de
	jp ti._idivu
.otherfs:
	ld bc,256
	cp a,1 ;alternative bosfs with 256b clusters
	jq z,.div
	
	ret


