
;@DOES Opens a file given a path and a file descriptor to start searching in. Returns file descriptor.
;@INPUT void *fs_OpenFileInDir(char *path, void *dir);
;@OUTPUT hl = file descriptor. hl is -1 if file does not exist, or if trying to start search in a file.
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
	ld hl,(ix+9)
	push hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_subdir,(hl)
	jr z,.fail
	call fs_GetFDPtr
	ex (sp),hl
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
