;@DOES get a pointer to a file's data section
;@INPUT void *fs_GetFilePtr(const char *path);
;@OUTPUT HL = file data pointer, BC = file data length, A = file flags, Cf set and HL = -1 if failed
fs_GetFilePtr:
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
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push hl
	bit fsbit_subfile, a
	jq z,.get_file_sector
	ld l,0
	res 0,h
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
