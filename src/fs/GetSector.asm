;@DOES get the sector a given address lies within
;@INPUT int fs_GetSector(void *address);
fs_GetSector:
	pop bc,hl
	push hl,bc
.entry:
	; ld a,(filesystem_driver)
	; or a,a
	ld de,-start_of_user_archive
	; jq nz,.otherfs
	ld c,fs_sector_size_bits
; .div:
	add hl,de
	jp ti._ishru
; .otherfs:
	; ld c,8
	; cp a,1 ;alternative bosfs with 256b clusters
	; jq z,.div
	
	; ret


