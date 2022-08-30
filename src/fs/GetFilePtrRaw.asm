;@DOES get a pointer to a file's data section
;@INPUT void *fs_GetFilePtrRaw(const char *path);
;@OUTPUT HL = file data pointer, BC = file data length, A = file flags, Cf set and HL = -1 if failed
fs_GetFilePtrRaw:
	pop bc,hl
	push hl,bc
.entryname:
	push hl
	call fs_OpenFile
	pop bc
	ret c
.entryfd:
	ld bc,fsentry_fileattr
	add hl,bc
	ld a,(hl)
	inc hl
	push af
	ld e,a
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,c
	and a,b
	inc a
	jr z,.fail ; fail if file data section hasn't been initialized yet
	inc hl
	push hl
	bit fd_subfile, e
	jr z,.get_file_sector
	ld a,l
	and a,not (fs_sector_size-1)
	ld l,a
	add hl,bc
	ex hl,de
	jr .located_file
.get_file_sector:
	push bc
	call fs_GetSectorAddress
	ex hl,de
	pop hl
.located_file:
	pop hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex hl,de
	pop af
	ret
.fail:
	pop af
	scf
	sbc hl,hl
	ret
