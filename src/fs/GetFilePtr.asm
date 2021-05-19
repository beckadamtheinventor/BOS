;@DOES get a pointer to a file's data section
;@INPUT void *fs_GetFilePtr(const char *path);
;@OUTPUT HL = file data pointer, BC = file data length, A = file flags, Cf set and HL = -1 if failed
fs_GetFilePtr:
	pop bc,hl
	push hl,bc,hl
	call fs_OpenFile
	pop bc
	ret c
	ld bc,$B
	add hl,bc
	ld a,(hl)
	inc hl
	push af
	ld de,(hl)
	push hl
	bit fsbit_subfile, a
	jq z,.get_file_sector
	ex.s hl,de
	ld e,0
	res 0,d
	add hl,de
	jq .located_file
.get_file_sector:
	push de
	call fs_GetSectorAddress
	ex hl,de
	pop hl
.located_file:
	pop hl
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex hl,de
	pop af
	ret
