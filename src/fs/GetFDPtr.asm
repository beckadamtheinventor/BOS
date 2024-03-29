;@DOES Return pointer to file data given a file descriptor
;@INPUT void *fs_GetFDPtr(void *fd);
;@OUTPUT pointer to file data, or -1 and Cf set if file data has not been allocated yet.
fs_GetFDPtr:
	pop bc,hl
	push hl,bc
.entry:
	ld bc,fsentry_filesector
	add hl,bc
	ld bc,(hl)
	ld a,c
	and a,b
	inc a
	jr nz,.hasdatasection
.retneg1:
	scf
	sbc hl,hl
	ret
.hasdatasection:
	dec hl
	ld a,(hl)
	ex hl,de
	sbc hl,hl
	ld l,c
	ld h,b
	bit fd_subfile,a
	jr z,fs_GetSectorAddress.entry
.subfile:
	ld a,e
	and a,not (fs_sector_size-1)
	ld e,a
	add hl,de
	ret
