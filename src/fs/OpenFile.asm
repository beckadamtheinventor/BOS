
;@DOES Opens a file from a path and returns file descriptor.
;@INPUT void *fs_OpenFile(char *path);
;@OUTPUT hl = file descriptor. hl is -1 if file does not exist.
;@DESTROYS All
;@NOTE This only searches for short 8.3 file names.
fs_OpenFile:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	cp a,' '
	jq z,.pathzero
	or a,a
	jq nz,.pathnonzero
.pathzero:
	ld hl,fs_filesystem_address
	ret ;return root directory
.pathnonzero:
	ld hl,-19
	call ti._frameset
	ld (ix-19),iy
	ld hl,(ix+6)
	push hl
	call fs_AbsPath
	pop bc
	inc hl
	ld (ix-3),hl
	ld iy,fs_filesystem_address
.entry:
.main_search_loop:
	ld hl,(ix-3)
	ld a,(hl)
	or a,a
	jq z,.return
	call .search_loop ;returns Zf if failed
	jq z,.fail
.into_dir:
	ld hl,(ix-3)
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,'/'
	cpir         ;get next path string
	jq nz,.return ;no more '/' found
	dec hl
.next_path_skip_slash_loop:
	cpi
	jq z,.next_path_skip_slash_loop
	dec hl
	ld (ix-3),hl ;advance path entry
	bit fsbit_subdirectory,(iy + fsentry_fileattr) ;check if we're entering a directory
	jq z,.fail ;trying to path into a file?
.step_into_dir:
	ld hl,(iy + fsentry_filesector) ;load file entry starting sector into hl
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	jq .main_search_loop
.return:
	xor a,a
	jq ._return
.fail:
	scf
	sbc hl,hl
	db $01 ;ld bc,...
._return:
	lea hl,iy ;is a 3 byte instruction
	ld iy,(ix-19) ;restore iy
	ld sp,ix
	pop ix
	ret

;searches for a file name in a directory listing
.search_next:
	lea iy,iy+16
.search_loop:
	ld a,(iy)
	or a,a
	ret z ;reached end of directory
	cp a,fsentry_deleted
	jq z,.search_next
	cp a,fsentry_longfilename
	jq z,.search_next
	lea bc,ix-16
	push iy,bc
	call fs_CopyFileName ;get file name string from file entry
	pop bc
	push bc
	call ti._strlen ;get length of file name string from file entry
	ex (sp),hl
	push hl
	ld bc,(ix-3)
	push bc
	call ti._memcmp ;compare with the target directory
	pop bc,bc,bc,iy
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,.search_next ;check next file entry
	xor a,a
	inc a
	ret

