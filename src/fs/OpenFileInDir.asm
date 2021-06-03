
;@DOES Opens a file given a path and a pointer to the dir to start searching from. Returns file descriptor.
;@INPUT void *fs_OpenFileInDir(char *path, void *dir);
;@OUTPUT hl = file descriptor. hl is -1 if file does not exist.
;@DESTROYS All
fs_OpenFileInDir:
	pop bc,hl,de
	push de,hl,bc
	ld a,(hl)
	cp a,' '
	jq z,.pathzero
	or a,a
	jq nz,.pathnonzero
.pathzero:
	ex hl,de
	ret ;return directory
.pathnonzero:
	ld hl,-26
	call ti._frameset
	ld (ix-20),iy
	ld hl,(ix+6)
	ld (ix-3),hl
	ld iy,(ix+9)
	ld de,(iy+fsentry_filesector)
	bit fsbit_subfile,(iy+fsentry_fileattr)
	jq z,.open_regular_file
	ex.s hl,de
	lea de,iy
	ld e,0
	res 0,d
	add hl,de
	push hl
	jq .open_from_stack
.open_regular_file:
	push de
	call fs_GetSectorAddress
	ex (sp),hl
.open_from_stack:
	pop iy
	call fs_OpenFile.entry
	jq c,.fail
	xor a,a
	lea hl,iy
	db $01
.fail:
	scf
	sbc hl,hl
._return:
	ld iy,(ix-20) ;restore iy
	ld sp,ix
	pop ix
	ret
