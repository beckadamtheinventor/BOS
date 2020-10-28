
;@DOES Opens a file given a path and a pointer to the dir to start searching from. Returns file descriptor.
;@INPUT void *fs_OpenFileInDir(char *path, void *dir);
;@OUTPUT hl = file descriptor. hl is -1 if file does not exist.
;@DESTROYS All
;@NOTE This only searches for short 8.3 file names.
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
	ld hl,-19
	call ti._frameset
	ld (ix-19),iy
	ld hl,(ix+6)
	ld (ix-3),hl
	ld iy,(ix+9)
	call fs_OpenFile.entry
	jq c,.fail
.return:
	xor a,a
	lea hl,iy
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
._return:
	ld iy,(ix-19) ;restore iy
	ld sp,ix
	pop ix
	ret
